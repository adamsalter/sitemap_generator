module SitemapGenerator
  class SitemapLocation < Hash

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
        :sitemaps_path => SitemapGenerator.app.root + 'public/',
        :public_path => nil,
        :host => nil,
        :filename => nil
      )
      self.merge!(opts)

      [:public_path, :filename, :sitemaps_path, :host].each do |method|
        define_method(method) do
          self[method] || raise "No value set for #{method}"
        end
      end
    end

    # Return a new Location instance with the given options merged in
    def with(opts={})
      self.merge(opts)
    end

    def filename
      self[:filename] && self[:filename].to_s || raise "No filename set"
    end

    # Full path to the directory of the file.
    def directory
      File.join(public_path, sitemaps_path)
    end

    # Full path of the file including the filename.
    def path
      File.join(public_path, sitemaps_path, filename)
    end

    # Full URL of the file.
    def url
      URI.join(host, sitemaps_path, filename).to_s
    end
  end
end