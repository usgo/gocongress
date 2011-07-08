module AttendeeHelper

  def address_without_linebreaks(a)
    "#{a.address_1} #{a.address_2} #{a.city}, #{a.state} #{a.zip} #{a.country}"
  end

end
