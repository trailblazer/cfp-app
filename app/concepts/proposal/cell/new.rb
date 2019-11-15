# frozen_string_literal: true

module Proposal::Cell
  class New < Form
    alias proposal model
    private

    def has_date_range?
      event_start_date && event_end_date
    end

    def event
      options[:event]
    end

    def event_start_date
      event.start_date
    end

    def event_end_date
      event.end_date
    end

    def event_status
      event.status
    end

    def event_closes_at
      event.closes_at.to_s(:month_day_year)
    end

    def event_date_range
      if (event.start_date.month == event.end_date.month) && (event.start_date.day != event.end_date.day)
        event.start_date.strftime('%b %d') + event.end_date.strftime(" \- %d, %Y")
      elsif (event.start_date.month == event.end_date.month) && (event.start_date.day == event.end_date.day)
        event.start_date.strftime('%b %d, %Y')
      else
        event.start_date.strftime('%b %d') + event.end_date.strftime(" \- %b %d, %Y")
      end
    end
  end
end
