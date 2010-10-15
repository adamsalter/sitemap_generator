module SitemapGenerator
  module Builder
    class SitemapIndexFile < SitemapFile
      attr_accessor :sitemaps

      def initialize(*args)
        super(*args)

        self.sitemaps = []
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

      # Finalize sitemaps as they are added to the index
      def add(link, options={})
        debugger
        if link.is_a?(SitemapFile)
          self.sitemaps << link
          link.finalize!
        end
        super(SitemapGenerator::Builder::SitemapIndexUrl.new(link, options))
      end

      # Return the total number of links in all sitemaps reference by this index file
      def total_link_count
        self.sitemaps.inject(0) { |link_count_sum, sitemap| link_count_sum + sitemap.link_count }
      end

      # Return a summary string
      def summary
        uncompressed_size = number_to_human_size(filesize)
        compressed_size =   number_to_human_size(File.size?(full_path))
        "+ #{'%-21s' % self.sitemap_path} #{'%10s' % self.link_count} sitemaps / #{'%10s' % uncompressed_size} / #{'%10s' % compressed_size} gzipped"
      end
    end
  end
end