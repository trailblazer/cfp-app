# frozen_string_literal: true

module Cfp
  module Cell
    class EventFooter < Trailblazer::Cell
      alias event model

      def current_event
        context[:current_event]
      end
    end
  end
end
