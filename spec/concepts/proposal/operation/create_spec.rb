require 'rails_helper'
describe Proposal::Operation::Create do

  subject(:result) { described_class.trace(params: params, current_user: current_user) }
  let(:current_user) { FactoryGirl.create(:user) }


  context "with valid params" do
    let(:params) {
      {
          event_slug: 'Lorem',
          proposal: {
              title: 'Foo',
              abstract: 'Abstract bar',
              details: 'About proposal',
              pitch: 'Elevator',
              session_format_id: session_format.id,
              speakers: [
                  {
                      bio: 'my bio'
                  }
              ]
          }
      }
    }

    context "with open event" do
      let!(:event) {
        FactoryGirl.create(:event, state: "open", slug: 'Lorem')
      }
      let!(:session_format) { SessionFormat.create(name: 'FooBar', event: event)}

      it "creates a proposal assigned to event identified by slug" do
        expect(result).to be_success
        expect(result[:model].title).to eq("Foo")
        expect(result[:model].persisted?).to be_truthy
        expect(result[:model].event).to eq(event)
      end

      it "assign current user as a speaker assigned to current event and filled with passed bio" do
        expect(result[:model].speakers[0].user).to eq(current_user)
        expect(result[:model].speakers[0].bio).to eq("my bio")
        expect(result[:model].speakers[0].event).to eq(event)
      end

      it "update speaker user bio from passed params" do
        expect(result[:model].speakers[0].user.bio).to eq("my bio")
      end
    end

    context "without event" do
      let(:session_format) { instance_double(SessionFormat, id: 53) }
      it "returns result object with an error about closed event without saving the proposal" do
        expect(result[:errors]).to eq("Event not found")
        expect(result).to be_failure
      end
    end

    context "with closed event" do
      let(:session_format) { instance_double(SessionFormat, id: 53) }
      let!(:event) { FactoryGirl.create(:event, state: "closed", closes_at: Time.now, slug: 'Lorem') }
      before do
        Timecop.freeze(event.closes_at + 2.hour)
      end
      after do
        Timecop.return
      end
      it "returns result object with an error about closed event without saving the proposal" do
        expect(result[:errors]).to eq("Event is closed")
        expect(result).to be_failure
      end
    end

    context "with event that was closed less than an hour age" do
      let(:session_format) { instance_double(SessionFormat, id: 53) }
      let!(:event) {
        FactoryGirl.create(:event,
            state: "closed", slug: 'Lorem', closes_at: Time.now
        ) }

      before do
        Timecop.freeze(event.closes_at + 40.minutes)
      end
      after do
        Timecop.return
      end
      it "it passes successfully" do
        expect(result[:errors]).to eq(nil)
        expect(result).to be_success
      end
    end
  end

end
