require 'builder'
require 'action_view'

# A LinkSet provisions a bunch of links to sitemap files.  It also writes the index file
# which lists all the sitemap files written.
module SitemapGenerator
  class LinkSet
    include ActionView::Helpers::NumberHelper  # for number_with_delimiter

    attr_accessor :default_host, :public_path, :sitemaps_path
    attr_accessor :sitemap, :sitemaps, :sitemap_index
    attr_accessor :verbose, :yahoo_app_id

    # Evaluate the sitemap config file and write all sitemaps.
    #
    # The Sitemap Interpreter includes the URL helpers and API methods
    # that the block argument to `add_links` is evaluted within.
    #
    # TODO: Refactor so that we can have multiple instances
    # of LinkSet.
    def create
      require 'sitemap_generator/interpreter'

      self.public_path = File.join(::Rails.root, 'public/') if self.public_path.nil?

      # Default host is not set yet.  Set it on these objects in `add_links`
      self.sitemap_index = SitemapGenerator::Builder::SitemapIndexFile.new(public_path, sitemap_index_path)
      self.sitemap = SitemapGenerator::Builder::SitemapFile.new(public_path, new_sitemap_path)

      start_time = Time.now
      SitemapGenerator::Interpreter.run
      self.sitemap_index.finalize!
      self.sitemap.finalize! unless self.sitemap.finalized?
      end_time = Time.now

      puts "\nSitemap stats: #{number_with_delimiter(self.link_count)} links / #{self.sitemaps.size} files / " + ("%dm%02ds" % (end_time - start_time).divmod(60)) if verbose
    end

    # Constructor
    #
    # <tt>public_path</tt> (optional) full path to the directory to write sitemaps in.
    #   Defaults to your Rails <tt>public/</tt> directory.
    #
    # <tt>sitemaps_path</tt> (optional) path fragment within public to write sitemaps
    #   to e.g. 'en/'.  Sitemaps are written to <tt>public_path</tt> + <tt>sitemaps_path</tt>
    #
    # <tt>default_host</tt> hostname including protocol to use in all sitemap links
    #   e.g. http://en.google.ca
    def initialize(public_path = nil, sitemaps_path = nil, default_host = nil)
      self.default_host = default_host
      self.public_path = public_path
      self.sitemaps_path = sitemaps_path

      # Completed sitemaps
      self.sitemaps = []
    end

    def link_count
      self.sitemaps.inject(0) { |link_count_sum, sitemap| link_count_sum + sitemap.link_count }
    end

    # Entry point for users.
    #
    # Called within the user's eval'ed sitemap config file.  Add links to sitemap files
    # passing a block.
    #
    # TODO: Refactor.  The call chain is confusing and convoluted here.
    def add_links
      raise ArgumentError, "Default hostname not set" if default_host.blank?

      # Set default host on the sitemap objects and seed the sitemap with the default links
      self.sitemap.hostname = self.sitemap_index.hostname = default_host
      self.sitemap << Link.generate('/', :lastmod => Time.now, :changefreq => 'always', :priority => 1.0)
      self.sitemap << Link.generate(self.sitemap_index, :lastmod => Time.now, :changefreq => 'always', :priority => 1.0)

      yield Mapper.new(self)
    end

    # Add a link to a Sitemap.  If a new Sitemap is required, one will be created for
    # you.
    #
    # Called from Mapper.
    def add_link(link)
      begin
        self.sitemap << link
      rescue SitemapGenerator::SitemapFull
        self.sitemap_index << Link.generate(self.sitemap)
        self.sitemaps << self.sitemap
        self.sitemap.summary if verbose

        self.sitemap = SitemapGenerator::Builder::SitemapFile.new(public_path, new_sitemap_path, default_host)
        self.sitemap << link
      rescue SitemapGenerator::SitemapFinalized
        self.sitemap = SitemapGenerator::Builder::SitemapFile.new(public_path, new_sitemap_path, default_host)
        self.sitemap << link
      end
    end

    # Ping search engines.
    #
    # @see http://en.wikipedia.org/wiki/Sitemap_index
    def ping_search_engines
      require 'open-uri'

      sitemap_index_url = CGI.escape(self.sitemap_index.full_url)
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

    protected

    # Return the current sitemap filename with index.
    #
    # The index depends on the length of the <tt>sitemaps</tt> array.
    def new_sitemap_path
      File.join(self.sitemaps_path || '', "sitemap#{self.sitemaps.length + 1}.xml.gz")
    end

    # Return the current sitemap index filename.
    #
    # At the moment we only support one index file which can link to
    # up to 50,000 sitemap files.
    def sitemap_index_path
      File.join(self.sitemaps_path || '', 'sitemap_index.xml.gz')
    end
  end
end