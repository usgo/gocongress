class Rpt::TshirtReportsController < Rpt::AbstractReportController

def show
  @attendees = Attendee.yr(@year).with_planlessness('planful'.to_sym)

  @sizes = {};
  @attendees.each do |attendee|
    # Create a key in the sizes hash for any new size
    if !@sizes[attendee.tshirt_size]
      @sizes[attendee.tshirt_size] = 0
    end

    @sizes[attendee.tshirt_size] += 1
  end

  @total_shirts = 0
  @sizes.each do |size, quantity|
    if size != 'NO'
      @total_shirts += quantity
    end
  end


  respond_to do |format|
    format.html do
      render :show
    end
  end
end

private

end
