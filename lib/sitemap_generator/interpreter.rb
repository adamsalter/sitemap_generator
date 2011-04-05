require 'sitemap_generator'

module SitemapGenerator

  # Evaluate a sitemap config file within the context of a class that includes the
  # Rails URL helpers.
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
    # @param sitemap a sitemap object
    # @param sitemap_config_file full path to the config file (default is config/sitemap.rb)
    def initialize(sitemap, sitemap_config_file=nil, &block)
      @sitemap = sitemap
      if block_given?
        instance_eval(&block)
      else
        sitemap_config_file ||= SitemapGenerator.app.root + 'config/sitemap.rb'
        eval(File.read(sitemap_config_file), nil, sitemap_config_file.to_s)
      end
    end

    def add(*args)
      @sitemap.add(*args)
    end
    
    def group(*args)
      @sitemap.group(*args)
    end
    
    # Evaluate the sitemap config file using the default sitemap.
    def self.run(*args, &block)
      new(SitemapGenerator::Sitemap, *args, &block)
    end
  end
end