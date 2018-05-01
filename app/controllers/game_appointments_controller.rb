class GameAppointmentsController < ApplicationController
  include YearlyController

  load_resource
  add_filter_to_set_resource_year
  # authorize_resource # TODO: fix authorization to use this
  # add_filter_restricting_resources_to_year_in_route

  before_action :find_game_appointment , only: [:show, :edit, :update, :destroy]

  def index
    @game_appointments = GameAppointment.all
    @import = GameAppointment::Import.new
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

<<<<<<< HEAD
  def edit
  end

  def create
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
=======
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
>>>>>>> Added Game Appointments
      end
    end
  end

<<<<<<< HEAD
=======
  # DELETE /game_appointments/1
  # DELETE /game_appointments/1.json
>>>>>>> Added Game Appointments
  def destroy
    @game_appointment.destroy
    respond_to do |format|
      format.html { redirect_to game_appointments_url, notice: 'Game Appointment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

<<<<<<< HEAD
  def import
    @round = Round.find(game_appointment_import_params[:round_id])
    @import = GameAppointment::Import.new  game_appointment_import_params
    if @import.save
      redirect_to round_path(@round.id), notice: "Imported #{@import.imported_count} game appointments"
    else
      count = @import.errors.count
      redirect_to round_path(@round.id), notice: "There were #{count} errors with your XML file: "
    end
  end

  def send_sms
    recipient = "#{@game_appointment.attendee.phone}"
    message = "Hello #{@game_appointment.attendee.full_name}. You are scheduled to play #{@game_appointment.opponent} in #{@game_appointment.location} at #{@game_appointment.time}."
    TwilioTextMessenger.new(message, recipient).call
    redirect_to game_appointments_url
  end

  private

=======
  private
  # Use callbacks to share common setup or constraints between actions.
  # See above ---> before_action :set_appointment, only: [:show, :edit, :update, :destroy]
>>>>>>> Added Game Appointments
  def find_game_appointment
    @game_appointment = GameAppointment.find(params[:id])
  end

<<<<<<< HEAD
  def game_appointment_import_params
    params.require(:game_appointment_import).permit(:file, :round_id)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def game_appointment_params
    params.require(:game_appointment).permit(:round_id, :attendee_one_id, :attendee_two_id, :location, :table, :time)
=======
  # Never trust parameters from the scary internet, only allow the white list through.
  def game_appointment_params
    params.require(:game_appointment).permit(:attendee_id, :opponent, :location, :time, :time_zone)
>>>>>>> Added Game Appointments
  end
end
