
module SitemapGenerator
  class Link
    attr_accessor :path, :priority, :changefreq, :lastmod, :host
  
    def initialize(path, options = {})
      options.assert_valid_keys(:priority, :changefreq, :lastmod, :host)
      options.reverse_merge!(:priority => 0.5, :changefreq => 'weekly', :lastmod => Time.now, :host => Sitemap.default_host)
      @path = path
      @priority = options[:priority]
      @changefreq = options[:changefreq]
      @lastmod = options[:lastmod]
      @host = options[:host]
    end
    
    def loc
      URI.join(@host, @path).to_s
    end
  end
end
