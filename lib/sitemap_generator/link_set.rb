module SitemapGenerator
  class LinkSet
    attr_accessor :default_host, :yahoo_app_id, :links

    def initialize
      @links = []
    end

    def default_host=(host)
      @default_host = host
      add_default_links
    end

    def add_default_links
      # Add default links
      @links << Link.generate('/', :lastmod => Time.now, :changefreq => 'always', :priority => 1.0)
      @links << Link.generate('/sitemap_index.xml.gz', :lastmod => Time.now, :changefreq => 'always', :priority => 1.0)
    end

    def add_links
      yield Mapper.new(self)
    end

    def add_link(link)
      @links << link
    end

    # Return groups with no more than maximum allowed links.
    def link_groups
      links.in_groups_of(SitemapGenerator::MAX_ENTRIES, false)
    end
  end
end
