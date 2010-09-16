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
    # This should be refactored so that we can have multiple instances
    # of LinkSet.
    def create
      require 'sitemap_generator/interpreter'

      self.public_path = File.join(::Rails.root, 'public/') if self.public_path.nil?

      start_time = Time.now
      SitemapGenerator::Interpreter.run
      finalize!
      end_time = Time.now

      puts "\nSitemap stats: #{number_with_delimiter(self.link_count)} links / #{self.sitemaps.size} files / " + ("%dm%02ds" % (end_time - start_time).divmod(60)) if verbose
    end

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

    # Called within the user's eval'ed sitemap config file.  Add links to sitemap files
    # passing a block.
    #
    # TODO: Refactor.  The call chain is confusing and convoluted here.
    def add_links
      raise ArgumentError, "Default hostname not set" if default_host.blank?

      # I'd rather have these calls in <tt>create</tt> but we have to wait
      # for <tt>default_host</tt> to be set by the user's sitemap config
      new_sitemap
      add_default_links

      yield Mapper.new(self)
    end

    # Called from Mapper.
    #
    # Add a link to the current sitemap.
    def add_link(link)
      unless self.sitemap << link
        new_sitemap
        self.sitemap << link
      end
    end

    # Add the current sitemap to the <tt>sitemaps</tt> Array and
    # start a new sitemap.
    #
    # If the current sitemap is nil or empty it is not added.
    def new_sitemap
      unless self.sitemap_index
        self.sitemap_index = SitemapGenerator::Builder::SitemapIndexFile.new(public_path, sitemap_index_path, default_host)
      end

      unless self.sitemap
        self.sitemap = SitemapGenerator::Builder::SitemapFile.new(public_path, new_sitemap_path, default_host)
      end

      # Mark the sitemap as complete and add it to the sitemap index
      unless self.sitemap.empty?
        self.sitemap.finalize!
        self.sitemap_index << Link.generate(self.sitemap)
        self.sitemaps << self.sitemap
        show_progress(self.sitemap) if verbose

        self.sitemap = SitemapGenerator::Builder::SitemapFile.new(public_path, new_sitemap_path, default_host)
      end
    end

    # Report progress line.
    def show_progress(sitemap)
      uncompressed_size = number_to_human_size(sitemap.filesize)
      compressed_size =   number_to_human_size(File.size?(sitemap.full_path))
      puts "+ #{sitemap.sitemap_path}   #{sitemap.link_count} links / #{uncompressed_size} / #{compressed_size} gzipped"
    end

    # Finalize all sitemap files
    def finalize!
      new_sitemap
      self.sitemap_index.finalize!
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

    def add_default_links
      self.sitemap << Link.generate('/', :lastmod => Time.now, :changefreq => 'always', :priority => 1.0)
      self.sitemap << Link.generate(self.sitemap_index, :lastmod => Time.now, :changefreq => 'always', :priority => 1.0)
    end

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