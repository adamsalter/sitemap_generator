require 'builder'

# A LinkSet provisions a bunch of links to sitemap files.  It also writes the index file
# which lists all the sitemap files written.
module SitemapGenerator
  class LinkSet

    attr_reader :default_host, :sitemaps_path, :filename
    attr_accessor :verbose, :yahoo_app_id, :include_root, :include_index, :sitemaps_host

    # Main entry-point.  Pass a block which contains calls to your URL helper methods
    # and sitemap methods like:
    #   +add+   - Add a link to the current sitemap
    #   +group+ - Start a new group of sitemaps
    #
    # The sitemaps are written as they get full and at the end of the block.
    #
    # All options are passed to this instance using accessor methods.  Any option
    # supported by +new+ can be passed.
    #
    # If the sitemap or index is finalized, a new one is created.  Generally
    # you shouldn't be calling +create+ more than once.
    def create(opts={}, &block)
      @sitemap_index = nil if @sitemap_index && @sitemap_index.finalized? && !@protect_index
      @sitemap = nil if @sitemap && @sitemap.finalized?
      set_options(opts)
      start_time = Time.now if verbose
      interpreter.eval(:yield_sitemap => @yield_sitemap || SitemapGenerator.yield_sitemap?, &block)
      finalize!
      end_time = Time.now if verbose
      puts sitemap_index.stats_summary(:time_taken => end_time - start_time) if verbose
    end

    # Dreprecated.  Use create.
    def add_links(&block)
      @yield_sitemap = true
      create(&block)
      @yield_sitemap = false
    end

    # Constructor
    #
    # == Options:
    # * <tt>:verbose</tt> - If +true+, output a summary line for each sitemap and sitemap
    #   index that is created.  Default is +false+.
    #
    # * <tt>:public_path</tt> - Full or relative path to the directory to write sitemaps into.
    #   Defaults to the <tt>public/</tt> directory in your application root directory or
    #   the current working directory.
    #
    # * <tt>:sitemaps_path</tt> - path fragment within public to write sitemaps
    #   to e.g. 'en/'.  Sitemaps are written to <tt>public_path</tt> + <tt>sitemaps_path</tt>
    #
    # * <tt>:default_host</tt> - host including protocol to use in all sitemap links
    #   e.g. http://en.google.ca
    #
    # * <tt>:filename</tt> - symbol giving the base name for files (default <tt>:sitemap</tt>).
    #   The sitemap names are generated like "#{filename}1.xml.gz", "#{filename}2.xml.gz"
    #   and the index name is like "#{filename}_index.xml.gz".
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
    #
    # * <tt>:sitemaps_namer</tt> - A +SitemapNamer+ instance for generating the sitemap names.
    def initialize(options={})

      # Option defaults
      options.reverse_merge!({
        :include_root => true,
        :include_index => true,
        :filename => :sitemap,
        :verbose => false
      })
      options.each_pair { |k, v| instance_variable_set("@#{k}".to_sym, v) }

      # If an index is passed in, protect it from modification.
      # Sitemaps can be added to the index but nothing else can be changed.
      if options[:sitemap_index]
        @protect_index = true
      end
    end

    # Add a link to a Sitemap.  If a new Sitemap is required, one will be created for
    # you.
    #
    # link - string link e.g. '/merchant', '/article/1' or whatever.
    # options - see README.
    #   host - host for the link, defaults to your <tt>default_host</tt>.
    def add(link, options={})
      add_default_links if !@added_default_links
      sitemap.add(link, options.reverse_merge!(:host => @default_host))
    rescue SitemapGenerator::SitemapFullError
      finalize_sitemap!
      retry
    rescue SitemapGenerator::SitemapFinalizedError
      @sitemap = sitemap.new
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
    # be finalized when the block returns.
    #
    # If you do not specify a <tt>:filename</tt> or a <tt>:sitemaps_path</tt> the filename
    # will be next one in the series.
    def group(opts={}, &block)
      @created_group = true
      opts = options_for_group(opts)

      # If no new filename or path is specified finalize the current sitemap
      # so that we don't overwrite it.
      if [:filename, :sitemaps_path, :sitemaps_namer].find { |key| opts.key?(key) }.nil?
        finalize_sitemap! if @sitemap && !@sitemap.empty?
      end

      @group = SitemapGenerator::LinkSet.new(opts)
      @group.create(&block) if block_given?
      @group
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

    def sitemaps_namer
      @sitemaps_namer ||= @sitemap && @sitemap.location.namer || SitemapGenerator::SitemapNamer.new(:sitemap)
    end

    def sitemap_index_namer
      @sitemap_index_namer ||= @sitemap_index && @sitemap_index.location.namer || SitemapGenerator::SitemapIndexNamer.new(:sitemap_index)
    end

    # Lazy-initialize a sitemap instance when it's accessed
    def sitemap
      @sitemap ||= SitemapGenerator::Builder::SitemapFile.new(
        :host => sitemaps_host,
        :namer => sitemaps_namer,
        :public_path => public_path,
        :sitemaps_path => @sitemaps_path
      )
    end

    # Lazy-initialize a sitemap index instance when it's accessed
    def sitemap_index
      @sitemap_index ||= SitemapGenerator::Builder::SitemapIndexFile.new(
        :host => sitemaps_host,
        :namer => sitemap_index_namer,
        :public_path => public_path,
        :sitemaps_path => @sitemaps_path
      )
    end

    def finalize!
      finalize_sitemap!
      finalize_sitemap_index!
    end

    protected

    # Set each option on this instance using accessor methods.  This will affect
    # both the sitemap and the sitemap index.
    def set_options(opts={})
      opts.each_pair do |key, value|
        send("#{key}=", value)
      end
    end

    # Return a hash of options which can be used to reconstruct this LinkSet instance.
    def get_options
      [:include_root, :include_index, :filename, :sitemaps_path, :public_path, :sitemaps_host, :verbose, :default_host].inject({}) do |hash, key|
        hash[key] = send(key)
        hash
      end
    end

    # Given +opts+, return a hash of options prepped for creating a new group from this LinkSet.
    # If <tt>:public_path</tt> is present in +opts+ it is removed because groups cannot
    # change the public path.
    def options_for_group(opts)
      opts.delete(:public_path)
      opts.reverse_merge!(
        :include_index => false,
        :include_root => false,
        :sitemap_index => sitemap_index
      )
      opts.reverse_merge!(get_options)
    end

    # Add default links if those options are turned on.  Record the fact that we have done so
    # in an instance variable.
    def add_default_links
      sitemap.add('/', :lastmod => Time.now, :changefreq => 'always', :priority => 1.0, :host => @default_host) if include_root
      sitemap.add(sitemap_index, :lastmod => Time.now, :changefreq => 'always', :priority => 1.0) if include_index
      @added_default_links = true
    end

    # Finalize a sitemap by including it in the index and outputting a summary line.
    # Do nothing if it has already been finalized.
    #
    # Don't finalize if the sitemap is empty and a group has been created.  The reason
    # being that the group will have written out its sitemap.
    #
    # Add the default links if they have not been added yet and no groups have been created.
    # If the default links haven't been added we know that the sitemap is empty,
    # because they are added on the first call to add().
    def finalize_sitemap!
      add_default_links if !@added_default_links && !@created_group
      return if sitemap.finalized? || sitemap.empty? && @created_group
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
      def default_host=(value)
        @default_host = value
        update_location_info(:host, value)
      end

      # Set the public_path.  This path gives the location of your public directory.
      # The default is the public/ directory in your Rails root.  Or if Rails is not
      # found, it defaults to public/ in the current directory (of the process).
      #
      # Example: 'tmp/' if you don't want to generate in public for some reason.
      #
      # Set to nil to use the current directory.
      def public_path=(value)
        @public_path = Pathname.new(value.to_s)
        @public_path = SitemapGenerator.app.root + @public_path if @public_path.relative?
        update_location_info(:public_path, @public_path)
        @public_path
      end

      # Return a Pathname with the full path to the public directory
      def public_path
        @public_path ||= self.send(:public_path=, 'public/')
      end

      # Set the sitemaps_path.  This path gives the location to write sitemaps to
      # relative to your public_path.
      # Example: 'sitemaps/' to generate your sitemaps in 'public/sitemaps/'.
      def sitemaps_path=(value)
        @sitemaps_path = value
        update_location_info(:sitemaps_path, value)
      end

      # Set the host name, including protocol, that will be used on all links to your sitemap
      # files.  Useful when the server that hosts the sitemaps is not on the same host as
      # the links in the sitemap.
      def sitemaps_host=(value)
        @sitemaps_host = value
        update_location_info(:host, value)
      end

      # Set the filename base to use when generating sitemaps and sitemap indexes.
      # The index name will be +value+ with <tt>_index.xml.gz</tt> appended.
      # === Example
      # <tt>filename = :sitemap</tt>
      def filename=(value)
        @filename = value
        self.sitemaps_namer = SitemapGenerator::SitemapNamer.new(@filename)
        self.sitemap_index_namer = SitemapGenerator::SitemapIndexNamer.new("#{@filename}_index")
      end

      # Set the namer to use when generating SitemapFiles (does not apply to the
      # SitemapIndexFile)
      def sitemaps_namer=(value)
        @sitemaps_namer = value
        @sitemap.location[:namer] = value if @sitemap && !@sitemap.finalized?
      end

      # Set the namer to use when generating SitemapFiles (does not apply to the
      # SitemapIndexFile)
      def sitemap_index_namer=(value)
        @sitemap_index_namer = value
        @sitemap_index.location[:namer] = value if @sitemap_index && !@sitemap_index.finalized? && !@protect_index
      end

      protected

      # Update the given attribute on the current sitemap index and sitemap file location objects.
      # But don't create the index or sitemap files yet if they are not already created.
      def update_location_info(attribute, value, opts={})
        opts.reverse_merge!(:include_index => !@protect_index)
        @sitemap_index.location[attribute] = value if opts[:include_index] && @sitemap_index && !@sitemap_index.finalized?
        @sitemap.location[attribute] = value if @sitemap && !@sitemap.finalized?
      end
    end
    include LocationHelpers
  end
end
