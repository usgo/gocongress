module HomeHelper
  
  def slideshow_image_tag(i)
    # img title becomes div.galleria-info-title
    # img alt becomes div.galleria-info-description
    slide_title = @slides[i-1][0]
    slide_author = @slides[i-1][1]
    slide_filename = ("%02d" % i) + ".jpg"
    slide_path = File.join("slideshow", @year.year.to_s, slide_filename)
    return image_tag slide_path, :title => slide_title, :alt => slide_author
  end
  
end
