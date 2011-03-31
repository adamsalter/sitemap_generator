module SitemapGenerator
  class SitemapLocation < Hash

    [:filename, :host].each do |method|
      define_method(method) do
        raise SitemapGenerator::SitemapError, "No value set for #{method}" unless self[method]
        self[method]
      end
    end

    [:public_path, :sitemaps_path].each do |method|
      define_method(method) do
        Pathname.new(self[method].nil? ? '' : self[method])
      end
    end

    # The filename is not required at initialization but must be set when calling
    # methods that depend on it like <tt>path</tt>.
    #
    # All options are optional.  Supported options are:
    #   public_path   - path to the "public" directory, or the directory you want to
    #                   write sitemaps in.  Default is a directory <tt>public/</tt>
    #                   in the current working directory, or relative to the Rails root
    #                   directory if running under Rails.
    #   sitemaps_path - gives the path relative to the <tt>public_path</tt> in which to
    #                 write sitemaps e.g. <tt>sitemaps/</tt>.
    #   host          - host name for URLs.  The full URL to the file is then constructed from
    #                   the <tt>host</tt>, <tt>sitemaps_path</tt> and <tt>filename</tt>
    #   filename      - name of the file
    def initialize(opts={})
      opts.reverse_merge!(
        :sitemaps_path => nil,
        :public_path => SitemapGenerator.app.root + 'public/',
        :host => nil,
        :filename => nil
      )
      self.merge!(opts)
    end

    # Return a new Location instance with the given options merged in
    def with(opts={})
      self.merge(opts)
    end

    # Full path to the directory of the file.
    def directory
      (public_path + sitemaps_path).to_s
    end

    # Full path of the file including the filename.
    def path
      (public_path + sitemaps_path + filename).to_s
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
  end
end