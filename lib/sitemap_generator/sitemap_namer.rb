module SitemapGenerator
  # A class for generating sitemap names given the base for the filename.
  #
  # === Example
  # namer = SitemapNamer.new(:sitemap)
  # namer.to_s => 'sitemap1.xml.gz'
  # namer.next.to_s => 'sitemap2.xml.gz'
  class SitemapNamer
    NameError = Class.new(StandardError)

    # Params:
    #   base - string or symbol that forms the base of the generated filename
    #
    # Options include:
    #   :extension - Default: '.xml.gz'. File extension to append.
    #   :start     - Default: 1. Numerical index at which to start counting.
    def initialize(base, options={});
      @options = SitemapGenerator::Utilities.reverse_merge(options,
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

  # A Namer for Sitemap Indexes.  The name never changes.
  class SitemapIndexNamer < SitemapNamer
    def to_s
      "#{@base}#{@options[:extension]}"
    end
  end

  # The SimpleNamer uses the same namer instance for the sitemap index and the sitemaps.
  # If no index is needed, the first sitemap gets the first name.  However, if
  # an index is needed, the index gets the first name.
  #
  # A typical sequence would looks like this:
  #   * sitemap.xml.gz
  #   * sitemap1.xml.gz
  #   * sitemap2.xml.gz
  #   * sitemap3.xml.gz
  #   * ...
  #
  # Options:
  #   :extension - Default: '.xml.gz'. File extension to append.
  #   :start     - Default: 1. Numerical index at which to start counting.
  #   :zero      - Default: nil.  Could be a string or number that gives part
  #                of the first name in the sequence.  So in the old naming scheme
  #                setting this to '_index' would produce 'sitemap_index.xml.gz' as
  #                the first name.  Thereafter, the numerical index defined by +start+
  #                is used.
  class SimpleNamer < SitemapNamer
    def initialize(base, options={})
      super_options = SitemapGenerator::Utilities.reverse_merge(options,
        :zero => nil # identifies the marker for the start of the series
      )
      super(base, super_options)
    end

    def to_s
      "#{@base}#{@count}#{@options[:extension]}"
    end

    # Reset to the first name
    def reset
      @count = @options[:zero]
    end

    # True if on the first name
    def start?
      @count == @options[:zero]
    end

    # Return this instance set to the next name
    def next
      if start?
        @count = @options[:start]
      else
        @count += 1
      end
      self
    end

    # Return this instance set to the previous name
    def previous
      raise NameError, "Already at the start of the series" if start?
      if @count <= @options[:start]
        @count = @options[:zero]
      else
        @count -= 1
      end
      self
    end
  end
end
