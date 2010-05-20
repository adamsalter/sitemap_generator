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

    def initialize(sitemap_config_file=nil)
      sitemap_config_file ||= File.join(::Rails.root, 'config/sitemap.rb')
      eval(open(sitemap_config_file).read)
    end

    # KJV do we need this?  We should be using path_* helpers.
    # def self.default_url_options(options = nil)
    #   { :host => SitemapGenerator::Sitemap.default_host }
    # end

    def self.run
      new
    end
  end
end