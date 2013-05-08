require 'nokogiri'
require 'ostruct'
require 'jsonify'

class KindleYourHighlights
  class XML
    def initialize(options)
      @file_name = options[:file_name] || "output_file"
      @list      = options[:list] || []
    end

    def save_as_format(str)
      File.open(@file_name, "w") do | f |
        f.puts str
      end
    end

    def output
      builder = Nokogiri::XML::Builder.new do | xml |
        xml.books {
          @list.books.each do | b |
            xml.book {
              xml.asin b.asin
              xml.title b.title
              xml.author b.author

              @list.highlights_hash[b.asin].each do | h |
                xml.highlights {
                  xml.annotation_id h.annotation_id
                  xml.content h.content
                }
              end
            }
          end
        }
      end

      save_as_format(builder.to_xml)
    end
  end

  class HTML
    def initialize(options)
      @file_name = options[:file_name] || "out.html"
      @dir_name  = File.expand_path(File.dirname(@file_name))
      @list      = options[:list] || []
    end

    def output
      create_directory
      output_json_file
      copy_files
    end

  private
    def output_json_file
      namespace = OpenStruct.new(:json_str => generate_json)
      template = ERB.new(File.read(Template.name("data.js.erb"))).result(namespace.instance_eval { binding })
      File.open(@dir_name + "/js/data.js", "w") {|f| f.puts template }
    end

    def generate_json
      json = Jsonify::Builder.new(:format => :pretty)
      json.info do
        json.total_books @list.books.length
        json.total_articles @list.highlights.length
      end
      json.books(@list.books) do |b|
        json.bookid b.asin
        json.title b.title
        json.total @list.highlights_hash[b.asin].size
        json.last_update b.last_update
        json.articles(@list.highlights_hash[b.asin]) do |a|
          json.location a.location
          json.content a.content
          json.note a.note
          json.link a.link
        end
      end
      json.compile!
    end

    def create_directory
      mkdir(@dir_name + "/js")
    end

    def copy_files
      FileUtils.cp(Template.name("kindle.html"), @file_name)
      FileUtils.cp_r(Template.name("bootstrap"), @dir_name)
      FileUtils.cp_r(Template.name("js"), @dir_name)
    end

    def mkdir(dir_name)
      FileUtils.mkdir(dir_name) unless File.exist?(dir_name)
    end
  end

  class Template
    def self.name(name)
       File.expand_path(File.dirname(__FILE__) + "/../template/" + name)
    end
  end
end