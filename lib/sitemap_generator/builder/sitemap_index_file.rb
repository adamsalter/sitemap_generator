module SitemapGenerator
  module Builder
    class SitemapIndexFile < SitemapFile
      attr_accessor :sitemaps

      def initialize(opts={})
        @options = [:location, :filename]
        SitemapGenerator::Utilities.assert_valid_keys(opts, @options)

        @location = opts.delete(:location) || SitemapGenerator::SitemapLocation.new
        @filename = "#{opts.fetch(:filename, :sitemap_index)}.xml.gz"
        @location[:filename] = @filename
        
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

      # Finalize sitemaps as they are added to the index
      def add(link, options={})
        if file = link.is_a?(SitemapFile) && link
          @sitemaps_link_count += file.link_count
          file.finalize!
        end
        super(SitemapGenerator::Builder::SitemapIndexUrl.new(link, options))
      end

      # Return the total number of links in all sitemaps reference by this index file
      def total_link_count
        @sitemaps_link_count
      end

      # Set a new filename on the instance.  Should not include any extensions e.g. :sitemap_index
      def filename=(filename)
        @filename = @location[:filename] = "#{filename}_index.xml.gz"
      end

      # Return a summary string
      def summary(opts={})
        uncompressed_size = number_to_human_size(@filesize) rescue "#{@filesize / 8} KB"
        compressed_size =   number_to_human_size(@location.filesize) rescue "#{@location.filesize / 8} KB"
        "+ #{'%-21s' % @location.path_in_public} #{'%10s' % @link_count} sitemaps / #{'%10s' % uncompressed_size} / #{'%10s' % compressed_size} gzipped"
      end

      def stats_summary(opts={})
        str = "Sitemap stats: #{number_with_delimiter(@sitemaps_link_count)} links / #{@link_count} sitemaps"
        str += " / %dm%02ds" % opts[:time_taken].divmod(60) if opts[:time_taken]
      end
    end
  end
end