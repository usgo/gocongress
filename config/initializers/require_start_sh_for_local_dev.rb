if Rails.env == 'development' && !ENV['GOCONGRESS_WAS_STARTED_BY_START_SH']
  $stderr.puts 'Use script/start.sh to start the gocongress app in local dev'
  exit(1)
end
