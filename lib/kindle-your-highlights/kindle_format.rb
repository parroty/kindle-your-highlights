require 'nokogiri'
require 'ostruct'

class KindleYourHighlights
  class KindleFormat
    def initialize(options)
      @file_name = options[:file_name] || "output_file"
      @list      = options[:list] || []
    end

    def save_as_format(str)
      File.open(@file_name, "w") do | f |
        f.puts str
      end
    end
  end

  class XML < KindleFormat
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

  class HTML < KindleFormat
    def output
      output_html
      copy_styles
    end

  private
    def output_html
      file_name = File.dirname(__FILE__) + "/../template/kindle.html.erb"
      namespace = OpenStruct.new(:books => @list.books, :highlights => @list.highlights_hash)
      template = ERB.new(File.read(file_name)).result(namespace.instance_eval { binding })
      save_as_format(template)
    end

    def copy_styles
      src = File.dirname(__FILE__) + "/../template/bootstrap"
      FileUtils.cp_r(src, File::dirname(@file_name))
    end
  end
end