module SitemapGenerator
  # A poor excuse for an enumerator, but it will have to do.
  # Return an object with a method `next` that generates sitemaps with the given name
  # and an index appended.
  #
  # For example:
  #   SitemapNamer.new(:sitemap) generates 'sitemap1.xml.gz', 'sitemap2.xml.gz' etc
  class SitemapNamer
    NameError = Class.new(StandardError)

    # Params:
    #   base - string or symbol that forms the base of the generated filename
    #
    # Options include:
    #   :extension - Default: '.xml.gz'. File extension to append.
    #   :start     - Default: 1. Index at which to start counting.
    def initialize(base, options={});
      @options = options.reverse_merge(
        :extension => '.xml.gz',
        :start => 1
      )
      @base = base
      reset
    end

    def to_s
      "#{@base}#{@count}#{@options[:extension]}"
    end

    # Increment count and return self
    def next
      @count += 1
      self
    end

    # Decrement count and return self
    def previous
      raise NameError, "Already at the start of the series" if start?
      @count -= 1
      self
    end

    # Reset count to the starting index
    def reset
      @count = @options[:start]
    end

    def start?
      @count <= @options[:start]
    end
  end
end
