class TimeSlotSerializer < ActiveModel::Serializer
  attributes :conference_day, :start_time, :end_time, :program_session_id, :title, :presenter,
    :room, :track, :description

  #NOTE: object references a TimeSlotDecorator

  def room
    object.room_name
  end

  def title
    object.session_title || object.title
  end

  def presenter
    object.session_presenter || object.presenter
  end

  def description
    object.session_description || object.description
  end

  def track
    object.session_track_name || object.track_name
  end
end
