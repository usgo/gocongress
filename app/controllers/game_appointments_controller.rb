class GameAppointmentsController < ApplicationController
  include YearlyController

  load_resource
  add_filter_to_set_resource_year
  # authorize_resource
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

  # GET /game_appointments/new
  def new
    @game_appointment = GameAppointment.new
    @game_appointment.year = @year.year
    @min_date = DateTime.now
  end

  # GET /game_appointments/1/edit
  def edit
  end

  # POST /game_appointments
  # POST /game_appointments.json
  def create

    Time.zone = game_appointment_params[:time_zone]


    respond_to do |format|
      if @game_appointment.save
        format.html { redirect_to game_appointments_path, notice: 'Game Appointment was successfully created.' }
        # format.json { render :show, status: :created, location: @game_appointment }
      else
        format.html { render :new }
        # format.json { render json: @game_appointment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /game_appointments/1
  # PATCH/PUT /game_appointments/1.json
  def update
    respond_to do |format|
      if @game_appointment.update(game_appointment_params)
        format.html { redirect_to @game_appointment, notice: 'Game Appointment was successfully updated.' }
        # format.json { render :show, status: :ok, location: @game_appointment }
      else
        format.html { render :edit }
        # format.json { render json: @game_appointment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /game_appointments/1
  # DELETE /game_appointments/1.json
  def destroy
    @game_appointment.destroy
    respond_to do |format|
      format.html { redirect_to game_appointments_url, notice: 'Game Appointment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  # See above ---> before_action :set_appointment, only: [:show, :edit, :update, :destroy]
  def find_game_appointment
    @game_appointment = GameAppointment.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def game_appointment_params
    params.require(:game_appointment).permit(:attendee_id, :opponent, :location, :time, :time_zone)
  end
end
