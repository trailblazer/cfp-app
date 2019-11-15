# frozen_string_literal: true

module Navigation
  module Staff
    module Cell
      class TrackRow < Trailblazer::Cell
        alias track model

        property :id
        property :name

        private

        def selected?
          id.to_s == options[:sticky_selected_track]
        end
      end
    end
  end
end
