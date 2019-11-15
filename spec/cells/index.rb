# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Proposal::Cell::Index, type: :cell do
  subject { cell(described_class, current_user, context: { current_user: current_user }).call(:show) }
  controller ProposalsController
  context 'cell rendering' do
    context 'without proposals' do
      let(:current_user) { FactoryGirl.create(:user) }
      it { expect(subject).to have_content("You don't have any proposals.") }
    end

    context 'with proposals' do
      let(:current_user) { FactoryGirl.create(:user) }
      let!(:proposal) { create :proposal }
      let!(:speaker) { create :speaker, user: current_user, proposal: proposal, event: proposal.event }

      it { expect(subject).to have_content proposal.title }
    end
  end
end
