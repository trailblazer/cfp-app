module Proposal::Operation
  class Create < Trailblazer::Operation
    class Present < Trailblazer::Operation
      step :model
      # we have to define which contract we use to build validation
      step Contract::Build(constant: Proposal::Contract::Create)
      # we have to define which key from params we use to pass params to contract
      step Contract::Validate(key: :proposal)

      def model(options, params:, **)
        options[:model] = Proposal.new
      end


    end
    step Nested(Present)
    step :event
    fail :event_not_found, fail_fast: true
    step :event_open?
    fail :event_not_open_error
    step Contract::Persist()



    def event_open?(ctx, **)
      ctx[:event].open?
    end

    def event(ctx, params:, **)
      ctx[:event] = Event.find_by(slug: params[:event_slug])
    end

    # -- bad stuff handled there --
    def event_not_found(ctx, **)
      ctx[:errors] =  "Event not found"
    end

    def event_not_open_error(ctx, **)
      ctx[:errors] = "Event is closed"
    end

  end

end