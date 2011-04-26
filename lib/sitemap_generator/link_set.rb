require 'builder'

# A LinkSet provisions a bunch of links to sitemap files.  It also writes the index file
# which lists all the sitemap files written.
module SitemapGenerator
  class LinkSet

    attr_reader :default_host, :public_path, :sitemaps_path, :filename, :sitemap, :location
    attr_accessor :verbose, :yahoo_app_id, :include_root, :include_index, :sitemaps_host


    # Main entry-point.  Pass a block which contains calls to your URL helper methods
    # and sitemap methods like:
    #   +add+   - Add a link to the current sitemap
    #   +group+ - Start a new group of sitemaps
    #
    # The sitemaps are written as they get full or at then end of the block.
    def create(&block)
      # Clear out the current objects.  New objects will be lazy-initialized.
      @sitemap_index = @sitemap = nil

      sitemap.add('/', :lastmod => Time.now, :changefreq => 'always', :priority => 1.0, :host => @location.host) if include_root
      sitemap.add(sitemap_index, :lastmod => Time.now, :changefreq => 'always', :priority => 1.0) if include_index

      start_time = Time.now
      interpreter.eval(:yield_sitemap => @yield_sitemap || SitemapGenerator.yield_sitemap?, &block)
      @yield_sitemap = false # needed to support old add_links call style
      finalize!
      end_time = Time.now
      puts sitemap_index.stats_summary(:time_taken => end_time - start_time) if verbose
    end

    # Constructor
    #
    # == Options:
    #
    # * <tt>:public_path</tt> - full path to the directory to write sitemaps in.
    #   Defaults to your Rails <tt>public/</tt> directory.
    #
    # * <tt>:sitemaps_path</tt> - path fragment within public to write sitemaps
    #   to e.g. 'en/'.  Sitemaps are written to <tt>public_path</tt> + <tt>sitemaps_path</tt>
    #
    # * <tt>:default_host</tt> - host including protocol to use in all sitemap links
    #   e.g. http://en.google.ca
    #
    # * <tt>:filename</tt> - symbol giving the base name for files (default <tt>:sitemap</tt>).
    #   The sitemap names are generated like "#{@filename}1.xml.gzip", "#{@filename}2.xml.gzip"
    #   and the index name is like "#{@filename}_index.xml.gzip".
    #
    # * <tt>:include_root</tt> - whether to include the root url i.e. '/' in each group of sitemaps.
    #   Default is false.
    #
    # * <tt>:include_index</tt> - whether to include the sitemap index URL in each group of sitemaps.
    #   Default is false.
    #
    # * <tt>:sitemaps_host</tt> - host (including protocol) to use in links to the sitemaps.  Useful if your sitemaps
    #   are hosted o different server e.g. 'http://amazon.aws.com/'
    #
    # * <tt>:sitemap_index</tt> - The sitemap index to use.  The index will not have its options modified
    #   when options are set on the LinkSet.
    def initialize(*args)

      # Extract options
      options = if (!args.first.nil? && !args.first.is_a?(Hash)) || args.size > 1
        warn "Deprecated. Please call with an options hash instead."
        [:public_path, :sitemaps_path, :default_host, :filename].each_with_index.inject({}) do |hash, arg|
          hash[arg[0]] = args[arg[1]]
          hash
        end
      else
        args.first || {}
      end

      # Option defaults
      options.reverse_merge!({
        :include_root => true,
        :include_index => true,
        :filename => :sitemap,
        :public_path => SitemapGenerator.app.root + 'public/',
        :sitemaps_path => nil,
        :sitemaps_host => nil
      })
      options.each_pair { |k, v| instance_variable_set("@#{k}".to_sym, v) }

      # Create a location object to store all the location options
      @location = SitemapGenerator::SitemapLocation.new(
        :sitemaps_path => @sitemaps_path,
        :public_path => @public_path,
        :host => @default_host
      )

      if options[:sitemap_index]
        @protect_index = true
      end
    end

    # Dreprecated.  Use create.
    def add_links(&block)
      @yield_sitemap = true
      create(&block)
    end

    # Add a link to a Sitemap.  If a new Sitemap is required, one will be created for
    # you.
    #
    # link - string link e.g. '/merchant', '/article/1' or whatever.
    # options - see README.
    #   host - host for the link, defaults to your <tt>default_host</tt>.
    def add(link, options={})
      sitemap.add(link, options.reverse_merge!(:host => @location.host))
    rescue SitemapGenerator::SitemapFullError
      finalize_sitemap!
      retry
    rescue SitemapGenerator::SitemapFinalizedError
      @sitemap = sitemap.next
      retry
    end

    # Create a new group of sitemaps.  Returns a new LinkSet instance with options set on it.
    #
    # All groups share this LinkSet's sitemap index, which is not modified by any of the options
    # passed to +group+.
    #
    # === Options
    # Any of the options to LinkSet.new.  Except for <tt>:public_path</tt> which is shared
    # by all groups.
    #
    # The current options are inherited by the new group of sitemaps.  The only exceptions 
    # being <tt>:include_index</tt> and <tt>:include_root</tt> which default to +false+.
    #
    # Pass a block to add links to the new LinkSet.  If you pass a block the sitemaps will
    # be finalized when the block returns.  The index will not be finalized.
    def group(opts={}, &block)
      opts.delete(:public_path)
      opts.reverse_merge!(
        :include_index => false,
        :include_root => false
      )
      opts.reverse_merge!([:include_root, :include_index, :filename, :sitemaps_path, :public_path, :sitemaps_host, :sitemap_index].inject({}) do |hash, key|
        hash[key] = send(key)
        hash
      end)

      linkset = SitemapGenerator::LinkSet.new(opts)
      if block_given?
        linkset.interpreter.eval(&block)
        linkset.finalize!
      end
      linkset
    end

    # Ping search engines.
    #
    # @see http://en.wikipedia.org/wiki/Sitemap_index
    def ping_search_engines
      require 'open-uri'

      sitemap_index_url = CGI.escape(sitemap_index.location.url)
      search_engines = {
        :google         => "http://www.google.com/webmasters/sitemaps/ping?sitemap=#{sitemap_index_url}",
        :yahoo          => "http://search.yahooapis.com/SiteExplorerService/V1/ping?sitemap=#{sitemap_index_url}&appid=#{yahoo_app_id}",
        :ask            => "http://submissions.ask.com/ping?sitemap=#{sitemap_index_url}",
        :bing           => "http://www.bing.com/webmaster/ping.aspx?siteMap=#{sitemap_index_url}",
        :sitemap_writer => "http://www.sitemapwriter.com/notify.php?crawler=all&url=#{sitemap_index_url}"
      }

      puts "\n" if verbose
      search_engines.each do |engine, link|
        next if engine == :yahoo && !self.yahoo_app_id
        begin
          Timeout::timeout(10) {
            open(link)
          }
          puts "Successful ping of #{engine.to_s.titleize}" if verbose
        rescue Timeout::Error, StandardError => e
          puts "Ping failed for #{engine.to_s.titleize}: #{e.inspect} (URL #{link})" if verbose
        end
      end

      if !self.yahoo_app_id && verbose
        puts "\n"
        puts <<-END.gsub(/^\s+/, '')
          To ping Yahoo you require a Yahoo AppID.  Add it to your config/sitemap.rb with:

          SitemapGenerator::Sitemap.yahoo_app_id = "my_app_id"

          For more information see http://developer.yahoo.com/search/siteexplorer/V1/updateNotification.html
        END
      end
    end

    # Return a count of the total number of links in all sitemaps
    def link_count
      sitemap_index.total_link_count
    end

    def sitemaps_host
      @sitemaps_host || @default_host
    end

    # Lazy-initialize a sitemap instance when it's accessed
    def sitemap(opts={})
      opts.reverse_merge!(
        :location => @location.dup.with(:host => @sitemaps_host || @default_host),
        :filename => @filename
      )
      @sitemap ||= SitemapGenerator::Builder::SitemapFile.new(opts)
    end

    # Lazy-initialize a sitemap index instance when it's accessed
    def sitemap_index
      @sitemap_index ||= SitemapGenerator::Builder::SitemapIndexFile.new(
        :location => @location.dup.with(:host => @sitemaps_host || @default_host),
        :filename => "#{@filename}_index"
      )
    end

    protected

    def finalize!
      finalize_sitemap!
      finalize_sitemap_index!
    end

    # Finalize a sitemap by including it in the index and outputting a summary line.
    # Do nothing if it has already been finalized.
    def finalize_sitemap!
      return if sitemap.finalized?
      sitemap_index.add(sitemap)
      puts sitemap.summary if verbose
    end

    # Finalize a sitemap index and output a summary line.  Do nothing if it has already
    # been finalized.
    def finalize_sitemap_index!
      return if @protect_index || sitemap_index.finalized?
      sitemap_index.finalize!
      puts sitemap_index.summary if verbose
    end

    # Return the interpreter linked to this instance.
    def interpreter
      require 'sitemap_generator/interpreter'
      @interpreter ||= SitemapGenerator::Interpreter.new(:link_set => self)
    end

    module LocationHelpers
      public

      # Set the host name, including protocol, that will be used by default on each
      # of your sitemap links.  You can pass a different host in your options to `add`
      # if you need to change it on a per-link basis.
      def default_host=(value, opts={})
        @default_host = value
        update_location_info(:host, value, opts)
      end

      # Set the public_path.  This path gives the location of your public directory.
      # The default is the public/ directory in your Rails root.  Or if Rails is not
      # found, it defaults to public/ in the current directory (of the process).
      #
      # Example: 'tmp/' if you don't want to generate in public for some reason.
      #
      # Set to nil to use the current directory.
      def public_path=(value, opts={})
        @public_path = value
        update_location_info(:public_path, value, opts)
      end

      # Set the sitemaps_path.  This path gives the location to write sitemaps to
      # relative to your public_path.
      # Example: 'sitemaps/' to generate your sitemaps in 'public/sitemaps/'.
      def sitemaps_path=(value, opts={})
        @sitemaps_path = value
        update_location_info(:sitemaps_path, value, opts)
      end

      # Set the host name, including protocol, that will be used on all links to your sitemap
      # files.  Useful when the server that hosts the sitemaps is not on the same host as
      # the links in the sitemap.
      def sitemaps_host=(value, opts={})
        opts.reverse_merge!(:and_self => false)
        @sitemaps_host = value
        update_location_info(:host, value, opts)
      end

      # Set the filename base to use when generating sitemaps and sitemap indexes.
      def filename=(value, opts={})
        @filename = value
        update_sitemap_info(:filename, value, opts)
      end

      protected

      # Update the given attribute on the current sitemap index and sitemap files.  But
      # don't create the index or sitemap files yet if they are not already created.
      def update_sitemap_info(attribute, value, opts={})
        opts.reverse_merge!(:include_index => !@protect_index)
        sitemap_index.send("#{attribute}=", value) if opts[:include_index] && @sitemap_index && !@sitemap_index.finalized?
        sitemap.send("#{attribute}=", value) if @sitemap && !@sitemap.finalized?
      end

      # Update the given attribute on the current sitemap index and sitemap file location objects.
      # But don't create the index or sitemap files yet if they are not already created.
      def update_location_info(attribute, value, opts={})
        opts.reverse_merge!(:and_self => true, :include_index => !@protect_index)
        @location.merge!(attribute => value) if opts[:and_self]
        sitemap_index.location.merge!(attribute => value) if opts[:include_index] && @sitemap_index && !@sitemap_index.finalized?
        sitemap.location.merge!(attribute => value) if @sitemap && !@sitemap.finalized?
      end
    end
    include LocationHelpers
  end
end
