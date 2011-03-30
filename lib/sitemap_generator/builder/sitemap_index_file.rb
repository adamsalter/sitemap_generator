module SitemapGenerator
  module Builder
    class SitemapIndexFile < SitemapFile
      attr_accessor :sitemaps

      def initialize(opts={})
        @options = [:directory, :host, :filename]
        @defaults = { :directory => 'public/', :filename => :sitemap_index }
        SitemapGenerator::Utilities.assert_valid_keys(opts, @options)
        opts.reverse_merge!(@defaults)
        opts.each_pair { |k, v| instance_variable_set("@#{k}".to_sym, v) }

        @link_count = 0
        @filename = "#{@filename}.xml.gz"
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
        @filename = "#{filename}.xml.gz"
      end

      # Return a summary string
      def summary(opts={})
        relative_path = (opts[:sitemaps_path] ? opts[:sitemaps_path] : '') + @filename
        uncompressed_size = number_to_human_size(@filesize) rescue "#{@filesize / 8} KB"
        compressed_size =   number_to_human_size(File.size?(path)) rescue "#{File.size?(path) / 8} KB"
        "+ #{'%-21s' % relative_path} #{'%10s' % @link_count} sitemaps / #{'%10s' % uncompressed_size} / #{'%10s' % compressed_size} gzipped"
      end

      def stats_summary(opts={})
        str = "Sitemap stats: #{number_with_delimiter(@sitemaps_link_count)} links / #{@link_count} sitemaps"
        str += " / %dm%02ds" % opts[:time_taken].divmod(60) if opts[:time_taken]
      end
    end
  end
end