require 'nokogiri'
require 'ostruct'

class KindleYourHighlights; end

class KindleYourHighlights::KindleFormat
  def initialize(options)
    @file_name   = options[:file_name] || "output"
    @output_path = options[:output_path] || "."
    @list        = options[:list] || []
  end

  def save_as_format(str)
    File.open([@output_path, @file_name].join("/"), "w") do | f |
      f.puts str
    end
  end
end

class KindleYourHighlights::XML < KindleYourHighlights::KindleFormat
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

class KindleYourHighlights::HTML < KindleYourHighlights::KindleFormat
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
    FileUtils.cp_r(src, @output_path)
  end
end
