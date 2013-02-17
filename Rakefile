require 'kindle-your-highlights'

DUMP_FILE = "output/dump/out.dump"
XML_FILE  = "output/xml/out.xml"
HTML_FILE = "output/html/out.html"

#---- UTILITY METHODS----
def ensure_output_path
  [DUMP_FILE, XML_FILE, HTML_FILE].each do |file|
    FileUtils.mkpath(File.dirname(file))
  end
end

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

def load_file
  list = KindleYourHighlights::List.load(DUMP_FILE)
end

def update_common(options)
  ensure_output_path
  kindle_list = yield init_kindle_object(options)
  kindle_list.dump(DUMP_FILE)
  convert_html
end


#----TASK ENTRY POINTS----
def update_recent
  update_common(:page_limit => 100, :day_limit => 31, :wait_time => 2) do |kindle|
    if File.exist?(DUMP_FILE)
      KindleYourHighlights::List.merge(kindle.list, KindleYourHighlights::List.load(DUMP_FILE))
    else
      kindle.list
    end
  end
end

def update_all
  update_common(:page_limit => 100, :wait_time => 2) do |kindle|
    kindle.list
  end
end

def print
  print_kindle_object(load_file)
end

def convert_html
  KindleYourHighlights::HTML.new(:list => load_file, :file_name => HTML_FILE).output
  puts "generated html file - #{HTML_FILE}"
end

def convert_xml
  KindleYourHighlights::XML.new(:list => load_file, :file_name => XML_FILE).output
  puts "generated xml file - #{XML_FILE}"
end


#----RAKE TASKS----
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
    convert_html
    convert_xml
  end

  desc 'load a local file and convert into html format'
  task :html do
    convert_html
  end

  desc 'load a local file and convert into xml format'
  task :xml do
    convert_xml
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
