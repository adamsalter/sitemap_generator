module SitemapGenerator
  class SitemapLocation < Hash

    [:host, :adapter].each do |method|
      define_method(method) do
        raise SitemapGenerator::SitemapError, "No value set for #{method}" unless self[method]
        self[method]
      end
    end

    [:public_path, :sitemaps_path].each do |method|
      define_method(method) do
        Pathname.new(self[method].nil? ? '' : self[method].to_s)
      end
    end

    # If no +filename+ or +namer+ is provided, the default namer is used.  For sitemap
    # files this generates names like <tt>sitemap1.xml.gz</tt>, <tt>sitemap2.xml.gz</tt> and so on,
    #
    # === Options
    # * <tt>adapter</tt> - SitemapGenerator::Adapter subclass
    # * <tt>filename</tt> - full name of the file e.g. <tt>'sitemap1.xml.gz'<tt>
    # * <tt>host</tt> - host name for URLs.  The full URL to the file is then constructed from
    #   the <tt>host</tt>, <tt>sitemaps_path</tt> and <tt>filename</tt>
    # * <tt>namer</tt> - a SitemapGenerator::SitemapNamer instance.  Can be passed instead of +filename+.
    # * <tt>public_path</tt> - path to the "public" directory, or the directory you want to
    #   write sitemaps in.  Default is a directory <tt>public/</tt>
    #   in the current working directory, or relative to the Rails root
    #   directory if running under Rails.
    # * <tt>sitemaps_path</tt> - gives the path relative to the <tt>public_path</tt> in which to
    #   write sitemaps e.g. <tt>sitemaps/</tt>.
    def initialize(opts={})
      SitemapGenerator::Utilities.assert_valid_keys(opts, [:adapter, :public_path, :sitemaps_path, :host, :filename, :namer])
      opts[:adapter] ||= SitemapGenerator::FileAdapter.new
      opts[:public_path] ||= SitemapGenerator.app.root + 'public/'
      opts[:namer] = SitemapGenerator::SitemapNamer.new(:sitemap) if !opts[:filename] && !opts[:namer]
      self.merge!(opts)
    end

    # Return a new Location instance with the given options merged in
    def with(opts={})
      self.merge(opts)
    end

    # Full path to the directory of the file.
    def directory
      (public_path + sitemaps_path).expand_path.to_s
    end

    # Full path of the file including the filename.
    def path
      (public_path + sitemaps_path + filename).expand_path.to_s
    end

    # Relative path of the file (including the filename) relative to <tt>public_path</tt>
    def path_in_public
      (sitemaps_path + filename).to_s
    end

    # Full URL of the file.
    def url
      URI.join(host, sitemaps_path.to_s, filename.to_s).to_s
    end

    # Return the size of the file at <tt>path</tt>
    def filesize
      File.size?(path)
    end

    # Return the filename.  Raises an exception if no filename or namer is set.
    # If using a namer once the filename has been retrieved from the namer its
    # value is locked so that it is unaffected by further changes to the namer.
    def filename
      raise SitemapGenerator::SitemapError, "No filename or namer set" unless self[:filename] || self[:namer]
      unless self[:filename]
        self.send(:[]=, :filename, self[:namer].to_s, :super => true)
      end
      self[:filename]
    end

    def namer
      self[:namer]
    end

    # If you set the filename, clear the namer and vice versa.
    def []=(key, value, opts={})
      if !opts[:super]
        case key
        when :namer
          super(:filename, nil)
        when :filename
          super(:namer, nil)
        end
      end
      super(key, value)
    end

    def write(data)
      adapter.write(self, data)
    end
  end

  class SitemapIndexLocation < SitemapLocation
    def initialize(opts={})
      if !opts[:filename] && !opts[:namer]
        opts[:namer] = SitemapGenerator::SitemapIndexNamer.new(:sitemap_index)
      end
      super(opts)
    end
  end
end
