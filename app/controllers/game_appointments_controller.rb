class GameAppointmentsController < ApplicationController
  include YearlyController

  load_resource
  add_filter_to_set_resource_year
  # authorize_resource # TODO: fix authorization to use this
  # add_filter_restricting_resources_to_year_in_route

  before_action :find_game_appointment , only: [:show, :edit, :update, :destroy]

  def index
    @game_appointments = GameAppointment.all
    if @game_appointments.length.zero?
      flash[:alert] = 'You have no game appointments. Create one now to get started.'
    end
  end

  def show
  end

  def new
    @game_appointment = GameAppointment.new
    @game_appointment.year = @year.year
    @min_date = DateTime.now
  end

  def edit
  end

  def create
    Time.zone = game_appointment_params[:time_zone]

    if @game_appointment.save
      redirect_to game_appointments_path, notice: 'Game Appointment was successfully created.'
    else
      render :new
    end
  end

  def update
    respond_to do |format|
      if @game_appointment.update(game_appointment_params)
        format.html { redirect_to game_appointments_url, notice: 'Game Appointment was successfully updated.' }
        format.json { render :index, status: :ok, location: @game_appointment }
      else
        format.html { render :edit }
        format.json { render json: @game_appointment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @game_appointment.destroy
    respond_to do |format|
      format.html { redirect_to game_appointments_url, notice: 'Game Appointment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def find_game_appointment
    @game_appointment = GameAppointment.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def game_appointment_params
    params.require(:game_appointment).permit(:attendee_id, :opponent, :location, :time, :time_zone)
  end
end
