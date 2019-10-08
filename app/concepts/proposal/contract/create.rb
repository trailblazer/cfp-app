module Proposal::Contract
  class Create < Reform::Form
    property :title
    property :abstract
    property :details
    property :pitch
    property :session_format_id
    property :event_id
    property :current_user, virtual: true
    validates :current_user, presence: true

    collection :speakers, populator: ->(model:, index:, **args) {

      model.insert(index,
        Speaker.find_or_initialize_by(user_id: current_user.id, event_id: self.event_id) )
    } do
      property :bio
      property :event_id
      property :user_id

      validates :event_id, presence: true
      validates :user_id, presence: true
      validates :bio, length: {maximum: 500}

    end
  end
end