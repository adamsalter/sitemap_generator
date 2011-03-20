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
    # Arguments:
    #
    # Options hash containing any of:
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
    # <tt>filename</tt> used in the name of the file like "#{@filename}1.xml.gzip" and "#{@filename}_index.xml.gzip"
    #   Defaults to <tt>sitemap</tt>
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
        :public_path => (File.join(::Rails.root, 'public/') rescue 'public/'),
        :sitemaps_path => './'
      })
      options.each_pair { |k, v| instance_variable_set("@#{k}".to_sym, v) }
    end

    # Entry point for users.
    #
    # Called within the user's eval'ed sitemap config file.  Add links to sitemap files
    # passing a block.
    #
    # TODO: Refactor.  The call chain is confusing and convoluted here.
    def add_links
      raise ArgumentError, "Default host not set" if default_host.blank?

      sitemap.add('/', :lastmod => Time.now, :changefreq => 'always', :priority => 1.0, :host => @default_host) if include_root
      sitemap.add(sitemap_index, :lastmod => Time.now, :changefreq => 'always', :priority => 1.0) if include_index

      yield self
    end

    # Add a link to a Sitemap.  If a new Sitemap is required, one will be created for
    # you.
    def add(link, options={})
      sitemap.add(link, options)
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

      sitemap_index_url = CGI.escape(sitemap_index.full_url)
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

    def link_count
      sitemap_index.total_link_count
    end

    def default_host=(value)
      @default_host = value
      sitemap_index.host = value unless sitemap_index.finalized?
      sitemap.host = value unless sitemap.finalized?
    end

    def public_path=(value)
      @public_path = value
      sitemap_index.directory = File.join(@public_path, @sitemaps_path) unless sitemap_index.finalized?
      sitemap.directory = File.join(@public_path, @sitemaps_path) unless sitemap.finalized?
    end

    def sitemaps_path=(value)
      @sitemaps_path = value
      sitemap_index.directory = File.join(@public_path, @sitemaps_path) unless sitemap_index.finalized?
      sitemap.directory = File.join(@public_path, @sitemaps_path) unless sitemap.finalized?
    end

    def filename=(value)
      @filename = value
      sitemap_index.filename = @filename unless sitemap_index.finalized?
      sitemap.filename = @filename unless sitemap.finalized?
    end

    # Lazy-initialize a sitemap instance when it's accessed
    def sitemap
      @sitemap ||= SitemapGenerator::Builder::SitemapFile.new(
        :directory => File.join(@public_path, @sitemaps_path),
        :filename => @filename,
        :host => @default_host
      )
    end

    # Lazy-initialize a sitemap index instance when it's accessed
    def sitemap_index
      @sitemap_index ||= SitemapGenerator::Builder::SitemapIndexFile.new(
        :directory => File.join(@public_path, @sitemaps_path),
        :filename => @filename,
        :host => @default_host
      )
    end
  end
end