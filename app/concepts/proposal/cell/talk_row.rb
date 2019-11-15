# frozen_string_literal: true

module Proposal::Cell
  class TalkRow < Trailblazer::Cell
    alias talk model
    property :event
    property :speakers
    property :session_format_name
    property :track_name
    property :updated_in_words
    property :public_comments

    private

    def talk_link
      link_to(talk.title, event_proposal_path(event_slug: options[:event].slug, uuid: talk))
    end

    def title
      'Speaker'.pluralize(speakers.size)
    end

    def speakers_collection
      speakers.collect(&:name).join(', ')
    end

    def comments
      pluralize(public_comments.size, 'comment')
    end
  end
end
