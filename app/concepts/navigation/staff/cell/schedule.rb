# frozen_string_literal: true

module Navigation
  module Staff
    module Cell
      class Schedule < Navigation::Cell::Main
        alias event model
        property :slug
      end
    end
  end
end
