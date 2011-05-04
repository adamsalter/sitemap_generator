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
    #   name - string or symbol that forms the base of the generated filename
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
      reset
    end

    # Return the next name in the sequence
    def next
      increment.name
    end

    def name
      increment if @count < @options[:start] # allows us to call namer.next or namer.current on a new namer and get the same result
      "#{@name}#{@count}#{@options[:extension]}"
    end
    alias_method :current, :name

    # Return the previous name in the sequence
    def previous
      decrement.name
    end

    # Reset count to the starting index
    def reset
      @count = @options[:start] - 1
    end

    # Increment count and return self
    def increment
      @count += 1
      self
    end

    # Decrement count and return self
    def decrement
      raise NameError, "Already at the first name in the series" if @count <= @options[:start]
      @count -= 1
      self
    end

    private


  end
end
