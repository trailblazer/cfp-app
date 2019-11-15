# frozen_string_literal: true

module Navigation
  module Cell
    class NotificationsList < Trailblazer::Cell
      def current_user
        context[:current_user]
      end

      def notifications_count
        current_user.notifications.unread.length
      end

      def notifications_more_unread_count
        current_user.notifications.more_unread_count
      end

      def notifications_unread
        current_user.notifications.recent_unread
      end

      def unread_notications?
        current_user.notifications.unread.any?
      end

      def more_unread_notifications?
        current_user.notifications.more_unread?
      end
    end
  end
end
