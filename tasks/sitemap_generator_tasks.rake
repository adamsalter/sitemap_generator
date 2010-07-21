environment = begin

  # Try to require the library.  If we are installed as a gem, this should work.
  # We don't need to load the environment.
  require 'sitemap_generator'
  []

rescue LoadError

  # We must be installed as a plugin.  Make sure the environment is loaded
  # when running all rake tasks.
  [:environment]

end

namespace :sitemap do
  desc "Install a default config/sitemap.rb file"
  task :install => environment do
    SitemapGenerator::Utilities.install_sitemap_rb(verbose)
  end

  desc "Delete all Sitemap files in public/ directory"
  task :clean => environment do
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