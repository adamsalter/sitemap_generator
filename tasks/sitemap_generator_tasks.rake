require 'zlib'
require 'sitemap_generator/helper'

namespace :sitemap do
  desc "Install a default config/sitemap.rb file"
  task :install do
    SitemapGenerator::Sitemap.install_sitemap_rb
  end

  desc "Delete all Sitemap files in public/ directory"
  task :clean do
    SitemapGenerator::Sitemap.clean_files
  end

  desc "Create Sitemap XML files in public/ directory (rake -s for no output)"
  task :refresh => ['sitemap:create'] do
    SitemapGenerator::Sitemap.ping_search_engines
  end

  desc "Create Sitemap XML files (don't ping search engines)"
  task 'refresh:no_ping' => ['sitemap:create']

  task :create => [:environment] do
    SitemapGenerator::Sitemap.create_files
  end
end
