module SitemapGenerator
  # Generator instances are used to build links.
  # The object passed to the add_links block in config/sitemap.rb is a Generator instance.
  class Mapper
    attr_accessor :set, :options

    def initialize(set, options={})
      @set = set
      @options = options
    end

    def add(loc, link = {})
      set.add_link Link.generate(loc, link), options
    end
  end
end
