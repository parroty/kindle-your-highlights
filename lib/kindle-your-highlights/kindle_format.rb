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
      @dir_name  = options[:dir_name] || "."
      @file_name = options[:file_name] || "out.html"
      @list      = options[:list] || []
    end

    def output
      generate_json
      copy_files
    end

  private
    def generate_json
      json = Jsonify::Builder.new(:format => :pretty)
      json.books(@list.books) do |b|
        json.bookid b.asin
        json.title b.title
        json.total @list.highlights_hash[b.asin].size
        json.last_update b.last_update
        json.articles(@list.highlights_hash[b.asin]) do |a|
          json.location a.location
          json.content a.content
        end
      end
      namespace = OpenStruct.new(:json_str => json.compile!)

      file_name = File.dirname(__FILE__) + "/../template/data.js.erb"
      template = ERB.new(File.read(file_name)).result(namespace.instance_eval { binding })

      File.open(File.dirname(__FILE__) + "/../template/js/data.js", "w") do |f|
        f.puts template
      end
    end

    def copy_files
      file_name = File.dirname(__FILE__) + "/../template/kindle.html"
      FileUtils.cp(file_name, @dir_name + "/" + @file_name)

      src = File.dirname(__FILE__) + "/../template/bootstrap"
      FileUtils.cp_r(src, @dir_name)

      src = File.dirname(__FILE__) + "/../template/js"

      js_dir_name = @dir_name + "js"
      FileUtils.mkdir(js_dir_name) unless Dir.exist?(js_dir_name)
      FileUtils.cp_r(src, @dir_name + "/js")
    end
  end
end