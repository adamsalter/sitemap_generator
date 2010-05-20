begin
  require 'sitemap_generator'
rescue LoadError, NameError
  # Application should work without vlad
end

namespace :sitemap do
  desc "Install a default config/sitemap.rb file"
  task :install do
    SitemapGenerator::Utilities.install_sitemap_rb(verbose)
  end

  desc "Delete all Sitemap files in public/ directory"
  task :clean do
    SitemapGenerator::Utilities.clean_files
  end

  desc "Create Sitemap XML files in public/ directory (rake -s for no output)"
  task :refresh => ['sitemap:create'] do
    SitemapGenerator::Sitemap.ping_search_engines
  end

  desc "Create Sitemap XML files (don't ping search engines)"
  task 'refresh:no_ping' => ['sitemap:create']

  task :create => [:environment] do
    SitemapGenerator::Sitemap.verbose = verbose
    SitemapGenerator::Sitemap.create
  end
end

