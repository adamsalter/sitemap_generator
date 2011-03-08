module SitemapGenerator
  # A poor excuse for an enumerator, but it will have to do.
  # Return an object with a method `next` that generates sitemaps with the given name
  # and an index appended.
  #
  # For example:
  #   SitemapNamer.new(:sitemap) generates 'sitemap1.xml.gz', 'sitemap2.xml.gz' etc
  class SitemapNamer
    # Params:
    #   name - string or symbol name that is the base of the generated filename
    #
    # Options include:
    #   :extension - Default: '.xml.gz'. File extension to append.
    #   :start     - Default: 1. Index at which to start counting.
    def initialize(name, options={});
      @options = options.reverse_merge(
        :extension => '.xml.gz',
        :start => 1
      )
      @name = name
      @count = @options[:start]
    end

    def next
      "#{@name}#{@count}#{@options[:extension]}"
    ensure
      @count += 1
    end
  end
end