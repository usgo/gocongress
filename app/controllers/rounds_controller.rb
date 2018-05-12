class RoundsController < ApplicationController
  include YearlyController
  load_resource
  add_filter_to_set_resource_year
  # authorize_resource # TODO: fix authorization to use this
  # add_filter_restricting_resources_to_year_in_route

  before_action :find_round , only: [:show, :edit, :update, :destroy]

  def index
    # @tournaments = Tournament.all
    @rounds = Round.all
    if @rounds.length.zero?
      flash[:alert] = 'You have no rounds. Create one now to get started.'
    end
  end

  def show
    @import = GameAppointment::Import.new
  end

  def new
    @round = Round.new
    @round.year = @year.year
    @min_date = DateTime.now
  end

  def edit
  end

  def create
    Time.zone = round_params[:time_zone]

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

  def send_sms_reminders
    game_appointments = @round.game_appointments
    game_appointments.each do |game_appointment|
      send_reminder(game_appointment.attendee_one, game_appointment) if game_appointment.attendee_one.receive_sms
      send_reminder(game_appointment.attendee_two, game_appointment) if game_appointment.attendee_two.receive_sms
    end
    redirect_to rounds_url, notice: 'Reminders Sent'

  end



  private

  def find_round
    @round = Round.find(params[:id])
  end

  def round_import_params
    params.require(:round_import).permit(:file)
  end

  def send_reminder(attendee, game_appointment)
    opponent = game_appointment.attendee_one == attendee ? game_appointment.attendee_two.full_name : game_appointment.attendee_one.full_name
    recipient = "#{attendee.local_phone}"
    message = "Hello #{attendee.full_name}. You are scheduled to play #{opponent} in #{game_appointment.location} at #{game_appointment.time}."
    puts recipient
    puts message

  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def round_params
    params.require(:round).permit(:number, :start_time, :tournament_id)
  end
end
