module Proposal::Operation
  class Create < Trailblazer::Operation

    step :event
    fail :event_not_found, fail_fast: true
    step Model(Proposal, :new)
    step :assign_event
    step Contract::Build(constant: Proposal::Contract::Create, builder: -> (ctx, constant:, model:,  **){
      constant.new(model, current_user: ctx[:current_user])
    })

    step :event_open?
    fail :event_not_open_error, fail_fast: true
    step Contract::Validate(key: :proposal)
    fail :validation_failed, fail_fast: true
    step Contract::Persist(method: :save)
    step :update_user_bio

    # -- methods --

    def assign_event(ctx, **)
      ctx[:model].event = ctx[:event]
    end

    def event(ctx, params:, **)
      ctx[:event] = Event.find_by(slug: params[:event_slug])
    end

    def event_open?(ctx, **)
      ctx[:event].open? && ctx[:event].closes_at >= 1.hour.since
    end

    def update_user_bio(ctx, **)
      ctx[:current_user].update(bio: ctx[:model].speakers[0][:bio])
    end

    # -- bad stuff handled there --


    def event_not_found(ctx, **)
      ctx[:errors] =  "Event not found"
    end

    def event_not_open_error(ctx, **)
      ctx[:errors] = "Event is closed"
    end

    def validation_failed(ctx, **)
      ctx[:errors] = ctx["contract.default"].errors.messages
    end

  end

end
