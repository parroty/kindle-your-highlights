require 'spec_helper'
require 'kindle-your-highlights'

USERNAME  = ENV["KINDLE_USERNAME"]
PASSWORD  = ENV["KINDLE_PASSWORD"]

DUMP_FILE = "spec/data/out.dump"
XML_FILE  = "spec/data/out.xml"
HTML_FILE = "spec/data/out.html"

describe "KindleYourHighlights" do
  it "loads data from server" do
    VCR.use_cassette('kindle_2_books') do
      kindle = KindleYourHighlights.new(USERNAME, PASSWORD, {:page_limit => 2, :wait_time => 2})
      kindle.list.books.length.should <= 2
    end
  end

  it "saves data to file" do
    File.delete(DUMP_FILE) if File.exist?(DUMP_FILE)

    VCR.use_cassette('kindle_2_books') do
      kindle = KindleYourHighlights.new(USERNAME, PASSWORD, {:page_limit => 2, :wait_time => 2})
      kindle.list.dump(DUMP_FILE)
      File.exist?(DUMP_FILE).should be_true
    end
  end

  it "loads data from file" do
    kindle = KindleYourHighlights::List.load(DUMP_FILE)
    kindle.books.length.should <= 2
  end
end
