require 'spec_helper'
require 'kindle-your-highlights'

USERNAME  = ENV["KINDLE_USERNAME"]
PASSWORD  = ENV["KINDLE_PASSWORD"]

DUMP_FILE = "spec/data/out.dump"
XML_FILE  = "spec/data/out.xml"
HTML_FILE = "spec/data/out.html"

describe "KindleYourHighlights" do
  describe "upto 2 books" do
    before(:all) do
      File.delete(DUMP_FILE) if File.exist?(DUMP_FILE)
    end

    it "loads data from server and saves them to file", :vcr do
      kindle = KindleYourHighlights.new(USERNAME, PASSWORD, {:page_limit => 2, :wait_time => 2})
      kindle.list.dump(DUMP_FILE)
      kindle.list.books.length.should have_at_least(1).items
      File.exist?(DUMP_FILE).should be_true
    end

    it "loads data from file" do
      kindle = KindleYourHighlights::List.load(DUMP_FILE)
      kindle.books.length.should have_at_least(1).items
    end
  end

  describe "all books", :slow => true do
    before(:all) do
      File.delete(DUMP_FILE) if File.exist?(DUMP_FILE)
    end

    it "loads data from server and saves them to file" do
      kindle = KindleYourHighlights.new(USERNAME, PASSWORD, {:page_limit => 10000, :wait_time => 2})
      kindle.list.dump(DUMP_FILE)
      File.exist?(DUMP_FILE).should be_true
    end
  end
end
