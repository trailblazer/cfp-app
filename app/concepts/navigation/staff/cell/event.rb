# frozen_string_literal: true

module Navigation
  module Staff
    module Cell
      class Event < Navigation::Cell::Main
        property :slug
        alias event model
      end
    end
  end
end
