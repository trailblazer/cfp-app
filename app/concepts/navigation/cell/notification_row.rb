# frozen_string_literal: true

module Navigation
  module Cell
    class NotificationRow < Trailblazer::Cell
      alias notification model

      property :short_message
    end
  end
end
