require 'builder'

# A LinkSet provisions a bunch of links to sitemap files.  It also writes the index file
# which lists all the sitemap files written.
module SitemapGenerator
  class LinkSet

    attr_reader :default_host, :public_path, :sitemaps_path, :filename, :sitemap
    attr_accessor :verbose, :yahoo_app_id, :include_root, :include_index

    # Evaluate the sitemap config file and write all sitemaps.
    #
    # The Sitemap Interpreter includes the URL helpers and API methods
    # that the block argument to `add_links` is evaluted within.
    #
    # TODO: Refactor so that we can have multiple instances
    # of LinkSet.
    def create(config_file = 'config/sitemap.rb', &block)
      require 'sitemap_generator/interpreter'

      start_time = Time.now
      @sitemap_index = @sitemap = nil

      SitemapGenerator::Interpreter.new(self, config_file, &block)
      unless sitemap.finalized?
        sitemap_index.add(sitemap)
        puts sitemap.summary if verbose
      end
      sitemap_index.finalize!
      end_time = Time.now

      if verbose
        puts sitemap_index.summary(:time_taken => end_time - start_time)
      end
    end

    # Constructor
    #
    # Call with a hash of options.  Options:
    #
    # <tt>public_path</tt> full path to the directory to write sitemaps in.
    #   Defaults to your Rails <tt>public/</tt> directory.
    #
    # <tt>sitemaps_path</tt> path fragment within public to write sitemaps
    #   to e.g. 'en/'.  Sitemaps are written to <tt>public_path</tt> + <tt>sitemaps_path</tt>
    #
    # <tt>default_host</tt> host including protocol to use in all sitemap links
    #   e.g. http://en.google.ca
    #
    # <tt>filename</tt> symbol giving the base name for files (default <tt>:sitemap</tt>).
    #   The sitemap names are generated like "#{@filename}1.xml.gzip", "#{@filename}2.xml.gzip"
    #   and the index name is like "#{@filename}_index.xml.gzip".
    #
    # <tt>include_root</tt> whether to include the root url i.e. '/' in each group of sitemaps.
    #   Default is false.
    #
    # <tt>include_index</tt> whether to include the sitemap index URL in each group of sitemaps.
    #   Default is false.
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
        :sitemaps_path => nil
      })
      options.each_pair { |k, v| instance_variable_set("@#{k}".to_sym, v) }
    end

    # Entry point for users.
    #
    # Called within the user's eval'ed sitemap config file.  Add links to sitemap files
    # passing a block.  This instance is passed in as an argument.  You can call
    # `add` on it to add links.
    #
    # Example:
    #   add_links do |sitemap|
    #     sitemap.add '/'
    #   end
    def add_links
      assert_default_host!

      sitemap.add('/', :lastmod => Time.now, :changefreq => 'always', :priority => 1.0, :host => @default_host) if include_root
      sitemap.add(sitemap_index, :lastmod => Time.now, :changefreq => 'always', :priority => 1.0) if include_index

      yield self
    end

    # Add a link to a Sitemap.  If a new Sitemap is required, one will be created for
    # you.
    #
    # link - string link e.g. '/merchant', '/article/1' or whatever.
    # options - see README.
    #   host - host for the link, defaults to your <tt>default_host</tt>.
    def add(link, options={})
      sitemap.add(link, options.reverse_merge!(:host => @default_host))
    rescue SitemapGenerator::SitemapFullError
      sitemap_index.add(sitemap)
      puts sitemap.summary if verbose
      retry
    rescue SitemapGenerator::SitemapFinalizedError
      @sitemap = sitemap.next
      retry
    end

    # Ping search engines.
    #
    # @see http://en.wikipedia.org/wiki/Sitemap_index
    def ping_search_engines
      require 'open-uri'

      sitemap_index_url = CGI.escape(sitemap_index.url)
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
          open(link)
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

    # Set the host name, including protocol, that will be used by default on each
    # of your sitemap links.  You can pass a different host in your options to `add`
    # if you need to change it on a per-link basis.
    def default_host=(value)
      @default_host = value
      update_sitemaps(:host)
    end

    # Set the public_path.  This path gives the location of your public directory.
    # The default is the public/ directory in your Rails root.  Or if Rails is not
    # found, it defaults to public/ in the current directory (of the process).
    #
    # Example: 'tmp/' if you don't want to generate in public for some reason.
    #
    # Set to nil to use the current directory.
    def public_path=(value)
      @public_path = value
      update_sitemaps(:directory)
    end

    # Set the sitemaps_path.  This path gives the location to write sitemaps to
    # relative to your public_path.
    # Example: 'sitemaps/' to generate your sitemaps in 'public/sitemaps/'.
    def sitemaps_path=(value)
      @sitemaps_path = value
      update_sitemaps(:directory)
    end

    def filename=(value)
      @filename = value
      update_sitemaps(:filename)
    end

    # Lazy-initialize a sitemap instance when it's accessed
    def sitemap
      @sitemap ||= SitemapGenerator::Builder::SitemapFile.new(
        :directory => sitemaps_directory,
        :filename => @filename,
        :host => sitemaps_url
      )
    end

    # Lazy-initialize a sitemap index instance when it's accessed
    def sitemap_index
      @sitemap_index ||= SitemapGenerator::Builder::SitemapIndexFile.new(
        :directory => sitemaps_directory,
        :filename => "#{@filename}_index",
        :host => sitemaps_url
      )
    end

    # Return the url to the sitemaps
    def sitemaps_url
      assert_default_host!
      URI.join(@default_host.to_s, @sitemaps_path.to_s).to_s
    end

    # Return the sitemaps directory
    def sitemaps_directory
      File.expand_path(File.join(@public_path.to_s, @sitemaps_path.to_s))
    end

    protected

    def assert_default_host!
      raise SitemapGenerator::SitemapError, "Default host not set" if @default_host.blank?
    end

    # Update the given attribute on the current sitemap index and sitemap files.  But
    # don't create the index or sitemap files yet if they are not already created.
    def update_sitemaps(attribute)
      return unless @sitemap || @sitemap_index
      value =
        case attribute
        when :host
          sitemaps_url
        when :directory
          sitemaps_directory
        when :filename
          @filename
        end
      sitemap_index.send("#{attribute}=", value) if @sitemap_index && !@sitemap_index.finalized?
      sitemap.send("#{attribute}=", value) if @sitemap && !@sitemap.finalized?
    end
  end
end