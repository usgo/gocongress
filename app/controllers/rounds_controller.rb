class RoundsController < ApplicationController
  include YearlyController
  load_resource
  add_filter_to_set_resource_year
  authorize_resource 
  add_filter_restricting_resources_to_year_in_route

  before_action :find_round , only: [:show, :edit, :update, :destroy]

  def index
    @rounds = Round.order('rounds.number ASC').all
    if @rounds.length.zero?
      flash[:alert] = 'You have no rounds. Create one now to get started.'
    end
  end

  def show
    @import = Round::Import.new(file: "",round_id: -1)
  end

  def new
    @round = Round.new
    @round.year = @year.year
    @min_date = DateTime.now
  end

  def edit
  end

  def create
    if @round.save
      redirect_to rounds_path, notice: 'Round was successfully created.'
    else
      render :new
    end
  end

  def update
    respond_to do |format|
      if @round.update(round_params)
        format.html { redirect_to rounds_url, notice: 'Round was successfully updated.' }
        format.json { render :index, status: :ok, location: @round }
      else
        format.html { render :edit }
        format.json { render json: @round.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @round.destroy
    respond_to do |format|
      format.html { redirect_to rounds_url, notice: 'Round was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def send_sms_notifications
    tournament = Tournament.find(@round.tournament_id)
    game_appointments = @round.game_appointments
    bye_appointments = @round.bye_appointments
    game_notifications_sent = 0
    bye_notifications_sent = 0

    game_appointments.each do |game_appointment|
      if game_appointment.attendee_one.receive_sms
        send_game_notification(game_appointment.attendee_one, tournament, @round, game_appointment)
        game_notifications_sent += 1
      end
      if game_appointment.attendee_two.receive_sms
        send_game_notification(game_appointment.attendee_two, tournament, @round, game_appointment)
        game_notifications_sent += 1
      end
    end
    if bye_appointments.any?
      bye_appointments.each do |bye|
        recipient = bye.attendee
        if recipient.receive_sms
          send_bye_notification(recipient, @round) 
          bye_notifications_sent += 1
        end
      end
    end
    redirect_to round_path(@round), notice: "#{game_notifications_sent} game #{'notification'.pluralize(game_notifications_sent)} sent." + "#{bye_notifications_sent} bye #{'notification'.pluralize(bye_notifications_sent)} sent."
  end

  def delete_all_game_appointments
    count = @round.game_appointments.count
    @round.game_appointments.destroy_all
    redirect_to round_path(@round), notice: count.to_s + " game #{"appointment".pluralize(count)} deleted."
  end

  def update_notification_message
    if @round.update(update_notification_message_params)
      redirect_to round_path(@round), notice: 'Round was successfully updated.'
    else
      format.html { render :index }
    end
  end

  def import
    @round = Round.find(round_import_params[:round_id])
    @import = Round::Import.new(file: round_import_params[:file], round_id: round_import_params[:round_id])
    if @import.save
      redirect_to round_path(@round.id), notice: "Imported #{@import.imported_game_count} game #{'appointment'.pluralize(@import.imported_game_count)}. Imported #{@import.imported_bye_count} bye #{'appointment'.pluralize(@import.imported_bye_count)}."
    else
      error_messages = @import.errors.full_messages
      redirect_to round_path(@round.id), alert: "File Upload failed with the following errors(limited to first five): #{error_messages.first(5)} "
    end
  end 

  private

  def find_round
    @round = Round.find(params[:id])
  end

  def update_notification_message_params
    params.require(:round).permit(:notification_message)
  end

  def round_import_params
    params.require(:round_import).permit(:file, :round_id)
  end

  def send_game_notification(attendee, tournament, round, game_appointment)
    recipient = "#{attendee.local_phone}"

    message = ""
    message += round.notification_message + " " unless round.notification_message.blank?

    message += "#{tournament.name}, Round #{round.number}: "\
    "#{game_appointment.attendee_one.full_name} (white) vs. "\
    "#{game_appointment.attendee_two.full_name} (black) at table "\
    "#{game_appointment.table} (#{game_appointment.location}). "\
    "Round #{round.number} starts at #{round.start_time.strftime('%H:%M %P')}"

    message += " on #{round.start_time.strftime('%B %e, %Y')}" unless round.start_time.today?
    message += "."

    TwilioTextMessenger.new(message, recipient).call

  end

  def send_bye_notification(attendee, round)
    recipient = "#{attendee.local_phone}"
    message = ""
    message += round.notification_message + " " unless round.notification_message.blank?
    message += "#{attendee.full_name} has received a bye for the #{round.tournament.name}, Round #{round.number}. "\
    "Round #{round.number} starts at #{round.start_time.strftime('%H:%M %P')}"

    message += " on #{round.start_time.strftime('%B %e, %Y')}" unless round.start_time.today?
    message += "."
    TwilioTextMessenger.new(message, recipient).call
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def round_params
    params.require(:round).permit(:number, :start_time, :tournament_id,
      :notification_message)
  end
end