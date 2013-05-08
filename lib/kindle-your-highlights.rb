require 'rubygems'
require 'selenium-webdriver'
require 'nokogiri'
require 'erb'
require 'date'
require 'kindle-your-highlights/kindle_format'

class KindleYourHighlights
  attr_accessor :highlights, :books

  WINDOW_WIDTH  = 320
  WINDOW_HEIGHT = 240

  DEFAULT_PAGE_LIMIT  = 1
  DEFAULT_DAY_LIMIT   = 365 * 100  # set default as 100 years
  DEFAULT_STOP_DATE   = nil  # nil means no stop date
  DEFAULT_WAIT_TIME   = 5
  DEFAULT_DRIVER_TYPE = :firefox

  def initialize(email_address, password, options = {}, &block)
    initialize_options(options)
    @block = block

    @driver = Selenium::WebDriver.for(@driver_type)
    @driver.manage.window.resize_to(WINDOW_WIDTH, WINDOW_WIDTH) if [:firefox, :ie].include?(@driver_type)

    begin
      @driver.navigate.to("https://www.amazon.com/ap/signin?openid.return_to=https%3A%2F%2Fkindle.amazon.com%3A443%2Fauthenticate%2Flogin_callback%3Fwctx%3D%252F&pageId=amzn_kindle&openid.mode=checkid_setup&openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0&openid.identity=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.pape.max_auth_age=0&openid.assoc_handle=amzn_kindle&openid.claimed_id=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select")

      element_email    = @driver.find_element(:name, 'email')
      element_password = @driver.find_element(:name, 'password')

      element_email.send_keys(email_address)
      element_password.send_keys(password)

      element_email.submit

      scrape_highlights
    ensure
      @driver.quit
    end
  end

  def initialize_options(options)
    @page_limit  = options[:page_limit]  || DEFAULT_PAGE_LIMIT
    @day_limit   = options[:day_limit]   || DEFAULT_DAY_LIMIT
    @wait_time   = options[:wait_time]   || DEFAULT_WAIT_TIME
    @stop_date   = options[:stop_date]   || DEFAULT_STOP_DATE
    @driver_type = options[:driver_type] || DEFAULT_DRIVER_TYPE
  end

  def scrape_highlights
    link = @driver.find_element(:link_text, "Your Highlights")
    link.click

    @books = []
    @highlights = []
    @page_limit.times do |cnt|
      @books      += collect_book
      @highlights += collect_highlight

      date_diff_from_today = (Date.today - Date.parse(@books.last.last_update)).to_i
      break if date_diff_from_today > @day_limit
      break if @stop_date and (Date.parse(@books.last.last_update) < @stop_date)

      break unless get_next_page

      sleep(@wait_time) if cnt != 0
      @block.call(self) if @block
    end
  end

  def list
    List.new(@books, @highlights)
  end

private
  def collect_book
    books = @driver.find_elements(:xpath, ".//div[@class='bookMain yourHighlightsHeader']")
    books.map { |b| Book.new(b) }
  end

  def collect_highlight
    highlights = @driver.find_elements(:xpath, ".//div[@class='highlightRow yourHighlight']")
    highlights.map { |h| Highlight.new(h) }.sort_by { |h| h.location }
  end

  def get_next_page
    begin
      element = @driver.find_element(:xpath, ".//a[@id='nextBookLink']")
      display_hidden_element(element)
      element.click
    rescue Selenium::WebDriver::Error::NoSuchElementError
      nil
    end
  end

  def display_hidden_element(element)
    @driver.execute_script("arguments[0].style.display='inline';", element)
  end
end

class KindleYourHighlights
  class List
    attr_accessor :books, :highlights, :highlights_hash

    def initialize(books, highlights)
      @books = books
      @highlights = highlights
      @highlights_hash = get_highlights_hash
    end

    def dump(file_name)
      File.open(file_name, "w") do |f|
        Marshal.dump(self, f)
      end
    end

    def self.load(file_name)
      Marshal.load(File.open(file_name))
    end

    def self.merge(base, append)
      books      = base.books.clone
      highlights = base.highlights.clone

      append.books.each do |b|
        books << b unless books.find { |item| item.asin == b.asin }
      end

      append.highlights.each do |h|
        highlights << h unless highlights.find { |item| item.annotation_id == h.annotation_id }
      end

      List.new(books, highlights)
    end

    def last_update
      books.map { |b| Date.parse(b.last_update) }.sort.last
    end

  private
    def get_highlights_hash
      hash = Hash.new([].freeze)
      @highlights.each do |h|
        hash[h.asin] += [h]
      end
      hash
    end
  end

  class Book
    attr_accessor :asin, :author, :title, :last_update

    @@amazon_items = Hash.new

    def initialize(item)
      @asin        = item.attribute('id').gsub(/_[0-9]+$/, "")
      @author      = item.find_element(:xpath, "span[@class='author']").text.gsub("\n", "").gsub("by", "").strip
      @title       = item.find_element(:xpath, "span/a").text
      @last_update = item.find_element(:xpath, "div[@class='lastHighlighted']").text

      @@amazon_items[@asin] = {:author => author, :title => title}
    end

    def self.find(asin)
      @@amazon_items[asin] || {:author => "", :title => ""}
    end
  end

  class Highlight
    attr_accessor :annotation_id, :asin, :author, :title, :content, :location, :note, :link

    @@amazon_items = Hash.new

    def initialize(item)
      @annotation_id  = item.find_element(:xpath, "form/input[@id='annotation_id']").attribute("value")
      @asin           = item.find_element(:xpath, "form/input[@id='asin']").attribute("value")
      @content        = item.find_element(:xpath, "span[@class='highlight']").text
      @note           = item.find_element(:xpath, "p/span[@class='noteContent']").text
      @link           = item.find_element(:xpath, "a[@class='k4pcReadMore readMore linkOut']").attribute("href")

      if @link =~ /location=([0-9]+)$/
        @location = $1.to_i
      end

      book = KindleYourHighlights::Book.find(@asin)
      @author = book[:author]
      @title  = book[:title]
    end
  end
end

