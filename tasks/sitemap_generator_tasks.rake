namespace :sitemap do
  # Require sitemap_generator at runtime.  If we don't do this the ActionView helpers are included
  # before the Rails environment can be loaded by other Rake tasks, which causes problems 
  # for those tasks when rendering using ActionView.
  task :require do
    require 'sitemap_generator'
  end

  desc "Install a default config/sitemap.rb file"
  task :install => ['sitemap:require'] do
    SitemapGenerator::Utilities.install_sitemap_rb(verbose)
  end

  desc "Delete all Sitemap files in public/ directory"
  task :clean => ['sitemap:require'] do
    SitemapGenerator::Utilities.clean_files
  end

  desc "Create Sitemap XML files in public/ directory (rake -s for no output)"
  task :refresh => ['sitemap:create'] do
    SitemapGenerator::Sitemap.ping_search_engines
  end

  desc "Create Sitemap XML files (don't ping search engines)"
  task 'refresh:no_ping' => ['sitemap:create']

  # Require sitemap_generator to handle the case that we are installed as a gem and are set to not
  # automatically be required.  If the library has already been required, this is harmless.
  task :create => [:environment, 'sitemap:require'] do
    SitemapGenerator::Sitemap.verbose = verbose
    SitemapGenerator::Sitemap.create
  end
end