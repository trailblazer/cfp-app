# frozen_string_literal: true

module Navigation
  module Cell
    class UserDropdown < Trailblazer::Cell
      private

      def user_name
        context[:current_user].name
      end

      def avatar
        image_tag("https://www.gravatar.com/avatar/#{context[:current_user].gravatar_hash}?s=25", class: 'user-dropdown-gravatar', alt: '')
      end
    end
  end
end
