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
        @written = false
        @reserved_name = nil # holds the name reserved from the namer
        @frozen = false      # rather than actually freeze, use this boolean
        @first_sitemap = nil # reference to the first thing added to this index
      end

      # Finalize sitemaps as they are added to the index.
      # If it's the first sitemap, finalize it but don't
      # write it out, because we don't yet know if we need an index.  If it's
      # the second sitemap, we know we need an index, so reserve a name for the
      # index, and go and write out the first sitemap.  If it's the third or
      # greater sitemap, just finalize and write it out as usual, nothing more
      # needs to be done.
      alias_method :super_add, :add
      def add(link, options={})
        if file = link.is_a?(SitemapFile) && link
          @sitemaps_link_count += file.link_count
          file.finalize! unless file.finalized?

          # First link.  If it's a SitemapFile store a reference to it and the options
          # so that we can create a URL from it later.  We can't create the URL yet
          # because doing so fixes the sitemap file's name, and we have to wait to see
          # if we have more than one link in the index before we can know who gets the
          # first name (the index, or the sitemap).  If the item is not a SitemapFile,
          # then it has been manually added and we can be sure that the user intends
          # for there to be an index.
          if @link_count == 0
            @first_sitemap = SitemapGenerator::Builder::LinkHolder.new(file, options)
            @link_count += 1      # pretend it's added
          elsif @link_count == 1  # adding second link, need an index so reserve names & write out first sitemap
            reserve_name unless @location.create_index == false # index gets first name
            write_first_sitemap
            file.write
            super(SitemapGenerator::Builder::SitemapIndexUrl.new(file, options))
          else
            file.write
            super(SitemapGenerator::Builder::SitemapIndexUrl.new(file, options))
          end
        else
          super(SitemapGenerator::Builder::SitemapIndexUrl.new(link, options))
        end
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

      def finalize!
        raise SitemapGenerator::SitemapFinalizedError if finalized?
        reserve_name if create_index?
        write_first_sitemap
        @frozen = true
      end

      # Write out the index if an index is needed
      def write
        super if create_index?
      end

      # Whether or not we need to create an index file.
      def create_index?
        @location.create_index == true || @location.create_index == :auto && @link_count > 1
      end

      protected

      # Make sure the first sitemap has been written out and added to the index
      def write_first_sitemap
        if @first_sitemap
          @first_sitemap.link.write unless @first_sitemap.link.written?
          super_add(SitemapGenerator::Builder::SitemapIndexUrl.new(@first_sitemap.link, @first_sitemap.options))
          @link_count -= 1   # we already counted it, don't count it twice
          @first_sitemap = nil
        end
      end
    end
  end
end
