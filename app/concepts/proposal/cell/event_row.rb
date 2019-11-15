# frozen_string_literal: true

module Proposal::Cell
  class EventRow < Trailblazer::Cell
    alias event model

    property :name
    property :status

    private

    def talks
      options[:proposals][event] || []
    end

    def invites
      options[:invitations][event] || []
    end

    def has_date_range?
      event.start_date? && event.end_date?
    end

    def status_class
      "event-status-badge event-status-#{event.status}"
    end

    def new_event_link
      link_to(
        'Submit a proposal',
        new_event_proposal_path(event.slug),
        class: 'btn btn-primary btn-sm'
      )
    end

    def guidelines_link
      link_to('View Guidelines', event_path(event.slug))
    end

    def date_range
      if (event.start_date.month == event.end_date.month) && (event.start_date.day != event.end_date.day)
        event.start_date.strftime('%b %d') + event.end_date.strftime(" \- %d, %Y")
      elsif (event.start_date.month == event.end_date.month) && (event.start_date.day == event.end_date.day)
        event.start_date.strftime('%b %d, %Y')
      else
        event.start_date.strftime('%b %d') + object.end_date.strftime(" \- %b %d, %Y")
      end
    end
  end
end
