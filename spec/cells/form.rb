# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Proposal::Cell::Form, type: :cell do
  subject { cell(described_class, current_user, context: { current_user: current_user }).call(:show) }
  # controller ProposalsController
  context 'with cell rendering' do
    let(:current_user) { FactoryGirl.create(:user) }
    let!(:event) { create :event }
    scenario 'renders a form' do

      expect(subject).to have_content proposal.title
    end
  end
end
