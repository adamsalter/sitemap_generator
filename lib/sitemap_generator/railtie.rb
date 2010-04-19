module SitemapGenerator
  class Railtie < Rails::Railtie
    rake_tasks do
      load File.expand_path('../../../tasks/sitemap_generator_tasks.rake', __FILE__)
    end
  end
end