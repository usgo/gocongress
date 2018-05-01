class GameAppointment::Import
  include ActiveModel::Model
  attr_accessor :file, :imported_count

  def process!
    errors.add(:base, "ERROR")
  end

  def save
    process!
    errors.none?
  end
end
