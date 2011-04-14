require 'sitemap_generator'

module SitemapGenerator

  # Provide a class for evaluating blocks, making the URL helpers from the framework
  # and API methods available to it.
  class Interpreter

    if SitemapGenerator.app.rails3?
      include ::Rails.application.routes.url_helpers
    elsif SitemapGenerator.app.rails?
      require 'action_controller'
      include ActionController::UrlWriter
    end

    # Call with a block to evaluate a dynamic config.  The only method exposed for you is
    # `add` to add a link to the sitemap object attached to this interpreter.
    #
    # Options:
    #   link_set - a LinkSet instance to use.  Default is SitemapGenerator::Sitemap
    def initialize(opts={}, &block)
      opts.reverse_merge!(:link_set => SitemapGenerator::Sitemap)
      @linkset = opts[:link_set]
      eval(&block) if block_given?
    end

    def add(*args)
      @linkset.add(*args)
    end

    # Start a new group of sitemaps.  Any of the options to SitemapGenerator.new may
    # be passed.  Pass a block with calls to +add+ to add links to the sitemaps.
    #
    # All groups use the same sitemap index.
    def group(*args, &block)
      @linkset.group(*args, &block)
    end

    # Evaluate the block in the interpreter.  Pass :yield_sitemap => true to
    # yield the Interpreter instance to the block...for old-style calling.
    def eval(opts={}, &block)
      if block_given?
        if opts[:yield_sitemap]
          yield self
        else
          instance_eval(&block)
        end
      end
    end

    # Pass the :config_file option to evaluate a specific config file.
    # Options:
    #   :config_file - full path to the config file (default is config/sitemap.rb in your root directory)
    def self.run(config_file=nil, &block)
      config_file ||= SitemapGenerator.app.root + 'config/sitemap.rb'
      eval(File.read(config_file), nil, config_file.to_s)
    end
  end
end
