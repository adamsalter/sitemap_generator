module SitemapGenerator
  module Builder
    class SitemapIndexFile < SitemapFile

      # === Options
      #
      # * <tt>location</tt> - a SitemapGenerator::SitemapIndexLocation instance or a Hash of options
      #   from which a SitemapLocation will be created for you.
      def initialize(opts={})
        @location = opts.is_a?(Hash) ? SitemapGenerator::SitemapIndexLocation.new(opts) : opts
        @link_count = 0
        @sitemaps_link_count = 0
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
        @filesize = bytesize(@xml_wrapper_start) + bytesize(@xml_wrapper_end)
      end

      # Finalize sitemaps as they are added to the index.
      def add(link, options={})
        if file = link.is_a?(SitemapFile) && link
          @sitemaps_link_count += file.link_count
          file.finalize! unless file.finalized?
        end
        super(SitemapGenerator::Builder::SitemapIndexUrl.new(link, options))
      end

      # Return a boolean indicating whether the sitemap file can fit another link
      # of <tt>bytes</tt> bytes in size.  You can also pass a string and the
      # bytesize will be calculated for you.
      def file_can_fit?(bytes)
        bytes = bytes.is_a?(String) ? bytesize(bytes) : bytes
        (@filesize + bytes) < SitemapGenerator::MAX_SITEMAP_FILESIZE && @link_count < SitemapGenerator::MAX_SITEMAP_FILES
      end

      # Return the total number of links in all sitemaps reference by this index file
      def total_link_count
        @sitemaps_link_count
      end

      # Return a summary string
      def summary(opts={})
        uncompressed_size = number_to_human_size(@filesize)
        compressed_size =   number_to_human_size(@location.filesize)
        path = ellipsis(@location.path_in_public, 44) # 47 - 3
        "+ #{'%-44s' % path} #{'%10s' % @link_count} sitemaps / #{'%10s' % compressed_size}"
      end

      def stats_summary(opts={})
        str = "Sitemap stats: #{number_with_delimiter(@sitemaps_link_count)} links / #{@link_count} sitemaps"
        str += " / %dm%02ds" % opts[:time_taken].divmod(60) if opts[:time_taken]
      end
    end
  end
end
