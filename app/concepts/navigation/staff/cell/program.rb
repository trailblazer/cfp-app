# frozen_string_literal: true

module Navigation
  module Staff
    module Cell
      class Program < Navigation::Cell::Main
        alias event model
        property :slug
        property :stats
        property :tracks

        private

        def program_tracks
          tracks&.any? ? tracks : []
        end

        def sticky_selected_track
          session["event/#{event.id}/program/track"]
        end

        def sticky_selected_track=(id)
          session["event/#{event.id}/program/track"] = id
        end

        def all_accepted_count
          stats.all_accepted_proposals
        end

        def all_waitlisted_count
          stats.all_waitlisted_proposals
        end

        def all_accepted_track_count
          stats.all_accepted_proposals(sticky_selected_track) if sticky_selected_track != 'all'
        end

        def all_waitlisted_track_count
          stats.all_waitlisted_proposals(sticky_selected_track) if sticky_selected_track != 'all'
        end

        def selected?
          sticky_selected_track.blank?
        end
      end
    end
  end
end
