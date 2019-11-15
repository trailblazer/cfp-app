# frozen_string_literal: true

module Proposal::Cell
  class InviteRow < Trailblazer::Cell
    alias invite model
    property :state
    property :proposal
    property :slug

    STATE_LABEL_MAP = {
      Invitation::State::PENDING => 'label-default',
      Invitation::State::DECLINED => 'label-danger',
      Invitation::State::ACCEPTED => 'label-success'
    }.freeze

    private

    def invitation_link
      link_to(invite.proposal.title, invitation_path(invite.slug))
    end

    def speakers
      invite.proposal.speakers.collect(&:name).join(', ')
    end

    def title
      'Speaker'.pluralize(invite.proposal.speakers.count)
    end

    def track_name
      proposal.track.try(:name) || Track::NO_TRACK
    end

    def label_class
      "label #{STATE_LABEL_MAP[state]}"
    end

    def decline_button(small: false)
      classes = 'btn btn-danger'
      classes += ' btn-xs' if small

      link_to 'Decline', decline_invitation_path(slug), class: classes,
                                                        data: { confirm: 'Are you sure you want to decline this invitation?' }
    end

    def accept_button(small: false)
      classes = 'btn btn-success'
      classes += ' btn-xs' if small

      link_to 'Accept', accept_invitation_path(slug), class: classes
    end
  end
end
