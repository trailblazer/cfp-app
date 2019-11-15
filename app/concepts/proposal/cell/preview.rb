# frozen_string_literal: true

module Proposal::Cell
  class Preview < Trailblazer::Cell
    alias proposal model
    property :tags
    property :tags_labels

    private

    def event
      options[:event]
    end

    def session_format_name
      proposal.session_format.try(:name)
    end

    def track_name
      proposal.track.try(:name) || Track::NO_TRACK
    end
  end
end
