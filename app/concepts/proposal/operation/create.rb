# frozen_string_literal: true

module Proposal::Operation
  class Create < Trailblazer::Operation
    class Present < Trailblazer::Operation
      step :event
      fail :event_not_found, fail_fast: true
      step Model(Proposal, :new)
      step :event_open?
      fail :event_not_open_error, fail_fast: true
      step :assign_event
      step Contract::Build(constant: Proposal::Contract::Create, builder: lambda { |ctx, constant:, model:, **|
                                                                            constant.new(model, current_user: ctx[:current_user])
                                                                          })

      def event(ctx, params:, **)
        ctx[:event] = Event.find_by(slug: params[:event_slug])
      end

      def assign_event(ctx, **)
        ctx[:model].event = ctx[:event]
      end

      def event_open?(_ctx, event:, **)
        return true if event.open?

        event.closes_at >= Time.now - 1.hour
      end

      def event_not_found(ctx, **)
        ctx[:errors] =  'Event not found'
      end

      def event_not_open_error(ctx, **)
        ctx[:errors] = 'Event is closed'
      end
    end
    step Contract::Validate(key: :proposal)
    fail :validation_failed, fail_fast: true
    step Contract::Persist(method: :save)
    step :update_user_bio

    # -- methods --

    def update_user_bio(ctx, **)
      ctx[:current_user].update(bio: ctx[:model].speakers[0][:bio])
    end

    # -- bad stuff handled there --

    def validation_failed(ctx, **)
      errors = ctx['contract.default'].errors.messages
      ctx[:errors] = errors.map { |field, msg| "#{field.to_s.capitalize} => #{msg.first}" }.join(', ')
    end
  end
end
