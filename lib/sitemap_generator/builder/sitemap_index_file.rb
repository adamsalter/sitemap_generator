module SitemapGenerator
  module Builder
    class SitemapIndexFile < SitemapFile

      def initialize(*args)
        super(*args)

        @xml_content = '' # XML urlset content
        @xml_wrapper_start = <<-HTML
          <?xml version="1.0" encoding="UTF-8"?>
            <sitemapindex
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9
                http://www.sitemaps.org/schemas/sitemap/0.9/siteindex.xsd"
              xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
            >
        HTML
        @xml_wrapper_start.gsub!(/\s+/, ' ').gsub!(/ *> */, '>').strip!
        @xml_wrapper_end   = %q[</sitemapindex>]
        self.filesize = bytesize(@xml_wrapper_start) + bytesize(@xml_wrapper_end)
      end

      # Return XML as a String
      def build_xml(builder, link)
        builder.sitemap do
          builder.loc        link[:loc]
          builder.lastmod    w3c_date(link[:lastmod])   if link[:lastmod]
        end
        builder << ''
      end
    end
  end
end