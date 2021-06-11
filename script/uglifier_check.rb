# Use this in combination with the rails console to troubleshoot javascript
# files if Uglifier is choking on something, and not offering any helpful
# debugging information on where or how.
#
# Run in the console with $ load './script/uglifier_check.rb'
#
# @see https://dev.to/jsrn/whats-tripping-up-uglifier-3j94
#
Dir["app/assets/javascripts/**/*.js"].each do |file_name|
  
    # ... run it through the uglifier on its own...
    print "."
    Uglifier.new(harmony: true).compile(File.read(file_name))
rescue StandardError => e
    # ... and tell us when there's a problem!
    puts "\nError compiling #{file_name}: #{e}\n"
  
end
