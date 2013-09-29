#!/usr/bin/env ruby

def die msg
  $stderr.puts msg
  exit 1
end

def die_with_usage
  die "Usage: hamlize.rb path/to/html.erb"
end

def main
  die_with_usage if ARGV.length != 1
  fn = ARGV[0].strip
  die_with_usage if fn.length == 0
  die "File not found: #{fn}" unless File.exists?(fn)
  die "Unexpected file extension" unless fn.match(/\.html.erb\z/)
  new_fn = fn.sub(/\.html.erb\z/, '.html.haml')
  system("html2haml -e #{fn} #{new_fn}")
  system("rm -i #{fn}")
end

main
