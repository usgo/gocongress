# frozen_string_literal: true

# Website metadata, to be visible whenever URLs are shared on social media.
class OpenGraphData
  attr_reader :image

  def initialize(year)
    raise TypeError unless year.is_a?(Year)
    @year = year
    @city = year.city
    @state = year.state
    @date_range = year.date_range
    @image = load_image
  end

  def description
    location = @year.event_type == "in-person" ? "#{@city}, #{@state}" : ""
    case @year.registration_phase
    when "canceled"
      description = event_title + " has been canceled."
    when "complete"
      description = event_title + " took place #{"in #{location} " unless location.empty?}from #{@date_range}."
    else
      description = event_title + " will " + (location.empty? ? "take place" : "be held in #{location},")
      description += " from #{@date_range}."
    end
    return description
  end

  def year
    @year.year
  end

  private

  def asset_exists?(path)
    !Rails.application.assets.find_asset(path).nil?
  end

  def event_title
    "The #{@year.year} U.S. #{'e-' if @year.event_type == 'online'}Go Congress"
  end

  def get_full_path_to_asset(filename)
    manifest_file = Rails.application.assets_manifest.assets[filename]
    if manifest_file
      File.join(Rails.application.assets_manifest.directory, manifest_file)
    else
      Rails.application.assets&.[](filename)&.filename
    end
  end

  def load_image
    og_image_path = "#{@year.year}/og-image.png"
    if asset_exists? og_image_path
      mm_image = MiniMagick::Image.open(get_full_path_to_asset(og_image_path))
      {
        path: og_image_path,
        width: mm_image[:width],
        height: mm_image[:height]
      }
    end
  end
end
