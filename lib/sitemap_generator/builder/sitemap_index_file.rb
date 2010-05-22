module SitemapGenerator
  module Builder
    class SitemapIndexFile < SitemapFile

      def initialize(*args)
        super(*args)

        @ml_content = ''     # XML urlset content
        @xml_wrapper_start = %q[<?xml version="1.0" encoding="UTF-8"?><sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">]
        @xml_wrapper_end   = %q[</sitemapindex>]
        self.filesize = @xml_wrapper_start.bytesize + @xml_wrapper_end.bytesize
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