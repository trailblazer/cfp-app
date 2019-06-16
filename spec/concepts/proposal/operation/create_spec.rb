require 'rails_helper'
describe Proposal::Operation::Create do

  subject(:result){ described_class.trace(params: params) }

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
              speakers_attributes: {
                  '0' => {
                      bio: 'my bio'
                  }
              }
          }
      }
    }

    context "with open event" do
      let!(:event) { Event.create(state: "open", slug: 'Lorem', name: 'Ipsum', url: 'http://www.correct.url') }
      let!(:session_format) { SessionFormat.create(name: 'FooBar', event: event)}
      it "creates a proposal" do
        expect(result).to be_truthy
        expect(result[:model].title).to eq("Foo")
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
      let!(:event) { Event.create(state: "closed", slug: 'Lorem', name: 'Ipsum', url: 'http://www.correct.url') }

      it "returns result object with an error about closed event without saving the proposal" do
        expect(result[:errors]).to eq("Event is closed")
        expect(result).to be_failure
      end
    end
  end

end
