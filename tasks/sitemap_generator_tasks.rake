require 'zlib'
require 'sitemap_generator/helper'

class SiteMapRefreshTask < Rake::Task
  include SitemapGenerator::Helper

  def execute(*)
    super
    ping_search_engines("sitemap_index.xml.gz")
  end
end

class SiteMapCreateTask < Rake::Task
  include SitemapGenerator::Helper
  include ActionView::Helpers::NumberHelper

  def execute(*)
    super
    build_files
  end

  private

  def build_files
    start_time = Time.now

    # update links from config/sitemap.rb
    load_sitemap_rb

    raise(ArgumentError, "Default hostname not defined") if SitemapGenerator::Sitemap.default_host.blank?

    Rake::Task['sitemap:clean'].invoke

    SitemapGenerator::Sitemap.render_sitemaps(verbose)

    SitemapGenerator::Sitemap.render_index(verbose)

    stop_time = Time.now
    puts "Sitemap stats: #{number_with_delimiter(SitemapGenerator::Sitemap.links.length)} links, " + ("%dm%02ds" % (stop_time - start_time).divmod(60)) if verbose
  end
end

namespace :sitemap do
  desc "Install a default config/sitemap.rb file"
  task :install do
    load File.expand_path(File.join(File.dirname(__FILE__), "../rails/install.rb"))
  end

  desc "Delete all Sitemap files in public/ directory"
  task :clean do
    sitemap_files = Dir[File.join(RAILS_ROOT, 'public/sitemap*.xml.gz')]
    FileUtils.rm sitemap_files
  end

  desc "Create Sitemap XML files in public/ directory (rake -s for no output)"
  SiteMapRefreshTask.define_task :refresh => ['sitemap:create']

  desc "Create Sitemap XML files (don't ping search engines)"
  task 'refresh:no_ping' => ['sitemap:create']

  SiteMapCreateTask.define_task :create => [:environment]
end
