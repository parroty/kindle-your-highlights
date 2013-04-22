require 'vcr'

VCR.configure do |c|
   c.cassette_library_dir = 'spec/data/vcr'
   c.hook_into :webmock
   c.allow_http_connections_when_no_cassette = true
   c.configure_rspec_metadata!
end

RSpec.configure do |c|
  c.treat_symbols_as_metadata_keys_with_true_values = true
  c.filter_run_excluding :slow => true
end
