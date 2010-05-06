module SitemapGenerator
  # Generator instances are used to build links.
  # The object passed to the add_links block in config/sitemap.rb is a Generator instance.
  class Mapper
    attr_accessor :set
    
    def initialize(set)
      @set = set
    end
    
    def add(loc, options = {})
      set.add_link Link.generate(loc, options)
    end
  end
end