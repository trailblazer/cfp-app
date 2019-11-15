require 'rails_helper'

describe ProposalsController, type: :controller do
  let(:event) { FactoryGirl.create(:event, state: "open") }

  describe 'GET #new' do
    let(:user) { create :user }
    let(:action) { :new }
    let(:params) do
      { event_slug: event.slug }
    end

    before { sign_in user }

    context 'user profile is complete' do
      it 'should succeed' do
        get :new, params: { event_slug: event.slug }
        expect(response.status).to eq(200)
      end

      it 'does not return a flash warning' do
        get :new, params: { event_slug: event.slug }
        expect(flash[:warning]).not_to be_present
      end
    end

    context 'user profile is incomplete' do
      let(:lead_in_msg) { 'Before submitting a proposal your profile needs completing. Please correct the following:' }
      let(:trailing_msg) { ". Visit <a href=\"/profile\">My Profile</a> to update." }

      it_behaves_like 'an incomplete profile notifier'
    end
  end

  describe 'POST #create' do
    let(:proposal) { build(:proposal, uuid: 'abc123') }
    let(:user) { create(:user) }
    let(:params) {
      {
        event_slug: event.slug,
        proposal: {
          title: proposal.title,
          abstract: proposal.abstract,
          details: proposal.details,
          pitch: proposal.pitch,
          session_format_id: proposal.session_format.id,
          speakers: [
            {
              bio: 'my bio'
            }
          ]
        }
      }
    }

    before { allow(controller).to receive(:current_user).and_return(user) }

    it "create Proposal" do
      expect{
        post :create, params: params
      }.to change{Proposal.count}.by(1)
    end

    it "sets the user's bio if not is present" do
      user.bio = nil
      post :create, params: params
      expect(user.bio).to eq('my bio')
    end

    context "event closed" do
      let!(:event) { FactoryGirl.create(:event, state: "closed", closes_at: Time.now - 20.years) }
      it "redirects to event show page with 'The CFP is closed for proposal submissions.'  message" do
        post :create, params: params
        expect(response).to redirect_to(event_path(event))
        expect(flash[:danger]).to match(/The CFP is closed for proposal submissions.*/)
      end
    end

    context "wrong slug passed" do
      let(:wrong_params) { params.merge(event_slug: 'Non-existing-slug')}
      it "re-render new form with 'Your event could not be found, please check the url.' message" do
        post :create, params: wrong_params
        expect(response).to redirect_to(events_path)
        expect(flash[:danger]).to match(/Your event could not be found, please check the url.*/)
      end
    end

  end

  describe "POST #confirm" do
    it "confirms a proposal" do
      proposal = create(:proposal, state: Proposal::ACCEPTED, confirmed_at: nil)
      allow_any_instance_of(ProposalsController).to receive(:current_user) { create(:speaker) }
      allow(controller).to receive(:require_speaker).and_return(nil)
      post :confirm, params: {event_slug: proposal.event.slug, uuid: proposal.uuid}
      expect(proposal.reload).to be_confirmed
    end

  end

  describe "POST #update_notes" do
    it "sets confirmation_notes" do
      proposal = create(:proposal, confirmation_notes: nil)
      allow_any_instance_of(ProposalsController).to receive(:current_user) { create(:speaker) }
      allow(controller).to receive(:require_speaker).and_return(nil)
      post :update_notes, params: {event_slug: proposal.event.slug, uuid: proposal.uuid,
           proposal: {confirmation_notes: 'notes'}}
      expect(proposal.reload.confirmation_notes).to eq('notes')
    end
  end

  describe 'POST #withdraw' do
    let(:proposal) { create(:proposal, event: event) }
    let(:user) { create(:user) }
    before { allow(controller).to receive(:current_user).and_return(user) }
    before { allow(controller).to receive(:require_speaker).and_return(nil) }

    it "sets the state to withdrawn for unconfirmed proposals" do
      post :withdraw, params: {event_slug: event.slug, uuid: proposal.uuid}
      expect(proposal.reload).to be_withdrawn
    end

    it "leaves state unchanged for confirmed proposals" do
      proposal.update_attribute(:confirmed_at, Time.now)
      post :withdraw, params: {event_slug: event.slug, uuid: proposal.uuid}
      expect(proposal.reload).not_to be_withdrawn
    end

    it "sends an in-app notification to reviewers" do
      create(:rating, proposal: proposal, user: create(:organizer))
      expect {
        post :withdraw, params: {event_slug: event.slug, uuid: proposal.uuid}
      }.to change { Notification.count }.by(1)
    end
  end

  describe 'PUT #update' do
    let(:speaker) { create(:speaker) }
    let(:proposal) { create(:proposal, speakers: [ speaker ] ) }

    before { sign_in(speaker.user) }

    it "updates a proposals attributes" do
      proposal.update(title: 'orig_title', pitch: 'orig_pitch')

      put :update, params: {event_slug: proposal.event.slug, uuid: proposal,
        proposal: { title: 'new_title', pitch: 'new_pitch' }}

      expect(assigns(:proposal).title).to eq('new_title')
      expect(assigns(:proposal).pitch).to eq('new_pitch')
      expect(assigns(:proposal).abstract).to_not match('<p>')
      expect(assigns(:proposal).abstract).to_not match('</p>')
    end

    it "sends a notifications to an organizer" do
      proposal.update(title: 'orig_title', pitch: 'orig_pitch')
      organizer = create(:organizer, event: proposal.event)
      create(:rating, proposal: proposal, user: organizer)

      expect {
        put :update, params: {event_slug: proposal.event.slug, uuid: proposal,
          proposal: { abstract: proposal.abstract, title: 'new_title',
                      pitch: 'new_pitch' }}
      }.to change { Notification.count }.by(1)
    end
  end
end
