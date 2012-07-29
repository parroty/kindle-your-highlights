Gem::Specification.new do |s|
  s.name        = 'kindle-your-highlights'
  s.version     = '0.1.0'
  s.summary     = "Kindle your highlights"
  s.description = "Scrape highlights from kinde.amazon.com"
  s.authors     = ["parroty"]
  s.email       = 'parroty00@gmail.com'
  s.files       = ["lib/kindle-your-highlights.rb"]
  s.homepage    = 'https://github.com/parroty/kindle-your-highlights'
 
  s.add_runtime_dependency 'mechanize', '>= 2.0.1'
end