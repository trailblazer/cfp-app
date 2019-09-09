module Proposal::Operation
  class Create < Trailblazer::Operation
    class Present < Trailblazer::Operation
      step Model(Proposal, :new)
      # we have to define which contract we use to build validation
      step Contract::Build(constant: Proposal::Contract::Create)
    end
    step Nested(Present)
    step Contract::Validate(key: :proposal)
    fail :validation_failed, fail_fast: true
    step :event
    fail :event_not_found, fail_fast: true
    step :event_open?
    fail :event_not_open_error
    step :assign_event
    # step :set_speaker_data
    step Contract::Persist(method: :save)
    # step :update_speaker_bio

    def assign_event(ctx, **)
      ctx[:model].event = ctx[:event]
    end

    def event(ctx, params:, **)
      ctx[:event] = Event.find_by(slug: params[:event_slug])
    end

    def event_open?(ctx, **)
      ctx[:event].open? && ctx[:event].closes_at >= 1.hour.since
    end
    #
    # def set_speaker_data(ctx, current_user:, **)
    #   ctx[:model].speakers[0].user_id = current_user.id
    #   ctx[:model].speakers[0].event_id = ctx[:event].id
    # end

    # -- bad stuff handled there --
    def validation_failed(ctx, **)
      ctx[:errors] = ctx["contract.default"].errors.messages
    end

    def event_not_found(ctx, **)
      ctx[:errors] =  "Event not found"
    end

    def event_not_open_error(ctx, **)
      ctx[:errors] = "Event is closed"
    end

  end

end
