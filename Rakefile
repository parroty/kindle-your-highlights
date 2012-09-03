require 'kindle-your-highlights'

DUMP_FILE = "../out.dump"
HTML_FILE = "../html/out.html"
XML_FILE  = "../xml/out.xml"

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
    kindle.merge!(KindleYourHighlights::List.load(DUMP_FILE))
  end
  kindle.list.dump(DUMP_FILE)

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
  KindleYourHighlights::HTML.new(:list => list, :file_name => HTML_FILE).output
  puts "generated html file - #{HTML_FILE}"
end

def xml
  list = KindleYourHighlights::List.load(DUMP_FILE)
  KindleYourHighlights::XML.new(:list => list, :file_name => XML_FILE).output
  puts "generated xml file - #{XML_FILE}"
end

task :default => :update

namespace :update do
  desc 'update recent data'
  task :recent do
    update_recent
  end

  desc 'retrieve all data'
  task :all do
    update_all
  end
end
desc 'call update:recent'
task :update => "update:recent"

namespace :convert do
  desc 'convert to all file types'
  task :all do
    html
    xml
  end

  desc 'convert to html file type'
  task :html do
    html
  end

  desc 'convert to xml file type'
  task :xml do
    xml
  end
end
desc 'call convert:all'
task :convert => "convert:all"

desc 'print highlight data'
task :print do
  print
end
