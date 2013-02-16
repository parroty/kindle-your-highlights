require 'kindle-your-highlights'

DUMP_FILE = "../out.dump"
XML_FILE  = "../xml/out.xml"
HTML_FILE = "../html/out.html"
HTML_DIR  = "../html"

def init_kindle_object(options)
  KindleYourHighlights.new(ENV["KINDLE_USERNAME"], ENV["KINDLE_PASSWORD"], options) do | h |
    puts "loading... [#{h.books.last.title}] - #{h.books.last.last_update}"
  end
end

def print_kindle_object(kindle_list)
  kindle_list.highlights.each_with_index do |obj, index|
    puts "HIGHLIGHT - #{index}"
    [:annotation_id, :content, :asin, :author, :title, :location, :note].each { |m| puts "  [#{m}] #{obj.send(m)}" }
  end

  kindle_list.books.each_with_index do |obj, index|
    puts "BOOK - #{index}"
    [:asin, :author, :title, :last_update].each { |m| puts "  [#{m}] #{obj.send(m)}" }
  end
end

def update_recent
  kindle = init_kindle_object(:page_limit => 100, :day_limit => 31, :wait_time => 2)

  if File.exist?(DUMP_FILE)
    org_list = KindleYourHighlights::List.load(DUMP_FILE)
    KindleYourHighlights::List.merge(kindle.list, org_list).dump(DUMP_FILE)
  else
    kindle.list.dump(DUMP_FILE)
  end

  html
end

def update_all
  kindle = init_kindle_object(:page_limit => 100, :wait_time => 2)
  kindle.list.dump(DUMP_FILE)

  html
end

def print
  list = KindleYourHighlights::List.load(DUMP_FILE)
  print_kindle_object(list)
end

def html
  list = KindleYourHighlights::List.load(DUMP_FILE)
  KindleYourHighlights::HTML.new(:list => list, :dir_name => HTML_DIR, :file_name => HTML_FILE).output
  puts "generated html directory - #{HTML_DIR}"
end

def xml
  list = KindleYourHighlights::List.load(DUMP_FILE)
  KindleYourHighlights::XML.new(:list => list, :file_name => XML_FILE).output
  puts "generated xml file - #{XML_FILE}"
end

task :default => :update

namespace :update do
  desc 'retrieve recent 1 month data from amazon server, and store them into a local file'
  task :recent do
    update_recent
  end

  desc 'retrieve all data from amazon server, and store them into a local file'
  task :all do
    update_all
  end
end
desc 'call update:recent'
task :update => "update:recent"

namespace :convert do
  desc 'load a local file and convert into xml/html format'
  task :all do
    html
    xml
  end

  desc 'load a local file and convert into html format'
  task :html do
    html
  end

  desc 'load a local file and convert into xml format'
  task :xml do
    xml
  end
end
desc 'call convert:all'
task :convert => "convert:all"

desc 'load a local file and print highlight data'
task :print do
  print
end

namespace :open do
  desc 'open html file'
  task :html do
    system('open', HTML_FILE) # TODO : mac only solution
  end

  desc 'open xml file'
  task :xml do
    system('open', XML_FILE) # TODO : mac only solution
  end
end
desc 'call open:html'
task :open => "open:html"
