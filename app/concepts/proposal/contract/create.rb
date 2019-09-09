module Proposal::Contract

  class Create < Reform::Form
    property :title
    property :abstract
    property :details
    property :pitch
    property :session_format_id
    property :current_user, virtual: true
    validates :current_user, presence: true

    collection :speakers, populator: ->(options, fragment:, model:, index:, **) {
      binding.pry;(item = model[index]) ? item : model.insert(index, Speaker.new(user_id: '23') ) } do
      # property :bio
      # property :event_id
      property :user_id
      #
      # validates :event_id, presence: true
      # validates :user_id, presence: true
      # validates :bio, length: {maximum: 500}
    end
  end
end