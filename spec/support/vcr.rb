VCR.configure do |c|
  # uncomment the following line to reset vcr
  # and run a smoke test
  # c.default_cassette_options = { record: :all }
  c.cassette_library_dir = "spec/cassettes"
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.ignore_localhost = true
  c.allow_http_connections_when_no_cassette = true
end
