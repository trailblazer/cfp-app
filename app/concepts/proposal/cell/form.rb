# frozen_string_literal: true

module Proposal::Cell
  class Form < Trailblazer::Cell
    include ActionView::RecordIdentifier
    include ActionView::Helpers::FormOptionsHelper
    include SimpleForm::ActionViewExtensions::FormHelper

    property :session_format_name
    property :tags

    def show
      render :form
    end

    private

    def title_input(form)
      form.input :title,
                 autofocus: true,
                 maxlength: :lookup, input_html: { class: 'watched js-maxlength-alert' },
                 hint: 'Publicly viewable title. Ideally catchy, interesting, essence of the talk. Limited to 60 characters.'
    end

    def markdown_link
      'https://help.github.com/articles/github-flavored-markdown'
    end

    def no_track_name_for_speakers
      "#{Track::NO_TRACK} - No Suggested Track"
    end

    def session_format_more_than_one?
      opts_session_formats.length > 1
    end

    def track_name_for_speakers
      proposal.track.try(:name) || no_track_name_for_speakers
    end

    def has_reviewer_activity?
      proposal.ratings.present? || proposal.has_reviewer_comments?
    end

    def multiple_tracks_without_activity?
      event.multiple_tracks? && !has_reviewer_activity?
    end

    def opts_session_formats
      event.session_formats.publicly_viewable.map { |st| [st.name, st.id] }
    end

    def opts_tracks
      event.tracks.sort_by_name.map { |t| [t.name, t.id] }
    end

    def abstract_tooltip
      'A concise, engaging description for the public program. Limited to 600 characters.'
    end

    def abstract_input(form, _abstract_tooltip = 'Proposal Abstract')
      form.input :abstract,
                 maxlength: 1000, input_html: { class: 'watched js-maxlength-alert', rows: 5 },
                 hint: 'A concise, engaging description for the public program. Limited to 1000 characters.' # , popover_icon: { content: tooltip }
    end

    def event
      options[:event]
    end
  end
end
