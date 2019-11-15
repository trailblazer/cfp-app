# frozen_string_literal: true

module Cfp
  module Cell
    class BaseLayout < Trailblazer::Cell
      private

      def current_user
        context[:current_user]
      end

      def title
        if @title.blank?
          'CFPApp'
        else
          @title
        end
      end

      def body_id
        "#{context[:controller].request.env['REQUEST_PATH']&.tr('/', '_')}_#{context[:controller].action_name}"
      end

      def show_flash
        context[:controller].flash.map do |key, value|
          key += ' alert-info' if key == 'notice'
          key = 'danger' if key == 'alert'
          content_tag(:div, class: "container alert alert-dismissable alert-#{key}") do
            content_tag(:button, content_tag(:span, '', class: 'glyphicon glyphicon-remove'),
                        class: 'close', data: { dismiss: 'alert' }) +
              simple_format(value)
          end
        end.join.html_safe
      end

      def current_event
        @current_event ||= set_current_event(session[:current_event_id]) if session[:current_event_id]
      end

      def set_current_event(event_id)
        @current_event = Event.find_by(id: event_id).try(:decorate)
        session[:current_event_id] = @current_event.try(:id)
        @current_event
      end
    end
  end
end
