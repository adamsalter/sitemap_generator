module SitemapGenerator

  # Evaluate a sitemap config file within the context of a class that includes the
  # Rails URL helpers.
  class Interpreter

    if SitemapGenerator::Utilities.rails3?
      include ::Rails.application.routes.url_helpers
    else
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
        sitemap_config_file ||= File.join(::Rails.root, 'config/sitemap.rb')
        eval(File.read(sitemap_config_file), nil, sitemap_config_file.to_s)
      end
    end

    def add(*args)
      @sitemap.add(*args)
    end

    # Evaluate the sitemap config file in this namespace which includes the
    # URL helpers.
    def self.run
      new(SitemapGenerator::Sitemap)
    end
  end
end