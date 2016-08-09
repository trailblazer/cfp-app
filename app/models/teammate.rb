class Teammate < ActiveRecord::Base

  PENDING = "pending"
  ACCEPTED = "accepted"
  DECLINED = "declined"
  STATES = ["pending", "accepted", "declined"]

  STAFF_ROLES = ['reviewer', 'program team', 'organizer']

  belongs_to :event
  belongs_to :user

  validates_uniqueness_of :email, scope: :event
  validates :email, :event, :role, presence: true
  validates_format_of :email, :with => /@/

  scope :for_event, -> (event) { where(event: event) }
  scope :alphabetize, -> { Teammate.joins(:user).merge(User.order(name: :asc)) }
  scope :notify, -> { where(notifications: true) }

  scope :organizer, -> { where(role: "organizer") }
  scope :program_team, -> { where(role: ["program team", "organizer"]) }
  scope :reviewer, -> { where(role: ["reviewer", "program team", "organizer"]) }

  scope :pending, -> { where(state: PENDING) }
  scope :accepted, -> { where(state: ACCEPTED) }
  scope :active, -> { where(state: ACCEPTED) }
  scope :declined, -> { where(state: DECLINED) }
  scope :invitations, -> { where(state: [PENDING, DECLINED]) }

  def accept(user)
    self.user = user
    self.accepted_at = Time.current
    self.state = ACCEPTED
    save
  end

  def decline
    self.declined_at = Time.current
    self.state = DECLINED
    save
  end

  def name
    user ? user.name : ""
  end

  def pending?
    state == PENDING
  end

  def invite
    self.token = Digest::SHA1.hexdigest(Time.current.to_s + email + rand(1000).to_s)
    self.state = PENDING
    self.invited_at = Time.current
    save
  end

  def comment_notifications
    if notifications
      "\u2713"
    else
      "X"
    end
  end

end

# == Schema Information
#
# Table name: teammates
#
#  id            :integer          not null, primary key
#  event_id      :integer
#  user_id       :integer
#  role          :string
#  email         :string
#  state         :string
#  token         :string
#  notifications :boolean          default(TRUE)
#  invited_at    :datetime
#  accepted_at   :datetime
#  declined_at   :datetime
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_teammates_on_event_id  (event_id)
#  index_teammates_on_user_id   (user_id)
#
