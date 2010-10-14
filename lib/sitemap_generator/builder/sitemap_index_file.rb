module SitemapGenerator
  module Builder
    class SitemapIndexFile < SitemapFile

      attr_accessor :sitemaps

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

      # Output a summary line
      def summary(start_time=nil, end_time=nil)
        puts "\nSitemap stats: #{number_with_delimiter(self.link_count)} links / #{self.sitemaps.size} files / "
        put ("%dm%02ds" % (end_time - start_time).divmod(60)) if start_time && end_time
      end

      # Finalize sitemaps as they are added to the index
      def add_link(link, options={})
        if link.is_a?(SitemapFile)
          self.sitemaps << link
          link.finalize!
        end
        super(SitemapGenerator::Builder::SitemapIndexUrl.new(link, options))
      end
    end
  end
end