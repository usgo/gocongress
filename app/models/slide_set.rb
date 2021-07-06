class SlideSet
  attr_reader :slides

  def initialize(year)
    conf_file = File.join(slides_dir(year), "slideshow.yml")
    @slides = File.exist?(conf_file) ?
      YAML.load_file(conf_file)["slides"] : []
  end

  # `slides_as_arrays` provides the legacy format
  # that the view helper expects.
  def slides_as_arrays
    return [] if @slides.nil?
    @slides.map { |s| [s["title"], s["subtitle"]] }
  end

  private

  def slides_dir(year)
    File.join(Rails.root, "app", "assets", "images", "slideshow", year.to_s)
  end
end
