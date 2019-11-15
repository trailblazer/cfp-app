# frozen_string_literal: true

class ProposalsController < ApplicationController
  before_action :require_event, except: %i[index create]
  before_action :require_user
  before_action :require_proposal, except: %i[index create new parse_edit_field]
  before_action :require_invite_or_speaker, only: [:show]
  before_action :require_speaker, except: %i[index create new parse_edit_field]

  include ApplicationHelper
  decorates_assigned :proposal

  def index
    render html: cell(Proposal::Cell::Index, current_user,
                      context: { current_user: current_user },
                      layout: Cfp::Cell::BaseLayout)
  end

  def new
    result = Proposal::Operation::Create::Present.call(params: params)
    if result[:errors] == 'Event is closed!'
      redirect_to event_path(result[:event])
      flash[:danger] = 'The CFP is closed for proposal submissions.'
      return
    else
      flash.now[:warning] = incomplete_profile_msg unless current_user.complete?
      render html: cell(Proposal::Cell::New, result[:model],
                        event: result[:event],
                        context: { current_user: current_user },
                        layout: Cfp::Cell::BaseLayout)
    end
  end

  def create
    result = ::Proposal::Operation::Create.(params: params, current_user: current_user)
    if result.success?
      flash[:info] = setup_flash_message(result[:model].event)
      redirect_to event_proposal_url(event_slug: result[:model].event.slug, uuid: result[:model])
    elsif result[:errors] == 'Event not found'
      flash[:danger] = 'Your event could not be found, please check the url.'
      redirect_to events_path
    elsif result[:errors] == 'Event is closed'
      flash[:danger] = 'The CFP is closed for proposal submissions.'
      redirect_to event_path(slug: result[:model].event.slug)
    else
      flash[:danger] = result[:errors]
      redirect_to event_path(slug: result[:model].event.slug)
    end
  end

  def confirm
    if @proposal.confirm
      flash[:success] = "You have confirmed your participation in #{@proposal.event.name}."
    else
      flash[:danger] = "There was a problem confirming your participation in #{@proposal.event.name}: #{@proposal.errors.full_messages.join(', ')}"
    end
    redirect_to event_proposal_path(slug: @proposal.event.slug, uuid: @proposal)
  end

  def update_notes
    if @proposal.update(confirmation_notes: notes_params[:confirmation_notes])
      flash[:success] = 'Confirmation notes successfully updated.'
      redirect_to event_proposal_path(slug: @proposal.event.slug, uuid: @proposal)
    else
      flash[:danger] = 'There was a problem updating confirmation notes.'
      render :show
    end
  end

  def withdraw
    @proposal.withdraw unless @proposal.confirmed?
    flash[:info] = 'As requested, your talk has been removed for consideration.'
    redirect_to event_proposal_url(slug: @proposal.event.slug, uuid: @proposal)
  end

  def destroy
    @proposal.destroy
    flash[:info] = 'Your proposal has been deleted.'
    redirect_to event_proposals_url
  end

  def show
    session[:event_id] = event.id

    render locals: {
      invitations: @proposal.invitations.not_accepted.decorate,
      event: @proposal.event.decorate
    }
  end

  def edit; end

  def update
    if params[:confirm]
      @proposal.update(confirmed_at: DateTime.current)
      redirect_to event_event_proposals_url(slug: @event.slug, uuid: @proposal), flash: { success: 'Thank you for confirming your participation' }
    elsif @proposal.update_and_send_notifications(proposal_params)
      redirect_to event_proposal_url(event_slug: @event.slug, uuid: @proposal)
    else
      flash[:danger] = 'There was a problem saving your proposal.'
      render :edit
    end
  end

  def parse_edit_field
    respond_to do |format|
      format.js do
        render locals: {
          field_id: params[:id],
          text: markdown(params[:text])
        }
      end
    end
  end

  private

  def proposal_params
    params.require(:proposal).permit(:title, { tags: [] }, :session_format_id, :track_id, :abstract, :details, :pitch, custom_fields: @event.custom_fields,
                                                                                                                       comments_attributes: %i[body proposal_id user_id],
                                                                                                                       speakers_attributes: %i[bio id])
  end

  def notes_params
    params.require(:proposal).permit(:confirmation_notes)
  end

  def require_invite_or_speaker
    unless @proposal.has_speaker?(current_user) || @proposal.has_invited?(current_user)
      redirect_to root_path
      flash[:danger] = 'You are not an invited speaker for the proposal you are trying to access.'
    end
  end

  def require_speaker
    unless @proposal.has_speaker?(current_user)
      redirect_to root_path
      flash[:danger] = 'You are not a listed speaker for the proposal you are trying to access.'
    end
  end

  def setup_flash_message(event)
    message = "Thank you! Your proposal has been submitted and may be reviewed at any time while the CFP is open.\n\n"
    message << "You are welcome to update your proposal or leave a comment at any time, just please be sure to preserve your anonymity.\n\n"

    if event.closes_at
      message << "Expect a response regarding acceptance after the CFP closes on #{event.closes_at.to_s(:long)}."
    end
  end

  def require_waitlisted_or_accepted_state
    unless @proposal.waitlisted? || @proposal.accepted?
      redirect_to event_url(@event.slug)
    end
  end

  def incomplete_profile_msg
    if profile_errors = current_user.profile_errors
      msg = 'Before submitting a proposal your profile needs completing. Please correct the following: '
      msg << profile_errors.full_messages.to_sentence
      msg << ". Visit #{view_context.link_to('My Profile', edit_profile_path)} to update."
      msg.html_safe
    end
  end
end
