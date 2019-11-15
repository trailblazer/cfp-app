# frozen_string_literal: true

module Proposal::Cell
  class Index < Trailblazer::Cell
    alias user model

    private

    def proposals
      user.proposals.decorate.group_by(&:event)
    end

    def no_proposals?
      proposals.blank? && invitations.blank?
    end

    def invitations
      user.pending_invitations.decorate.group_by { |inv| inv.proposal.event }
    end

    def events
      (proposals.keys | invitations.keys).uniq
    end
  end
end
