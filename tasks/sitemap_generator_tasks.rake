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

    link_groups = SitemapGenerator::Sitemap.link_groups
    raise(ArgumentError, "TOO MANY LINKS!! I really thought 2,500,000,000 links would be enough for anybody!") if link_groups.length > SitemapGenerator::MAX_ENTRIES

    Rake::Task['sitemap:clean'].invoke

    # render individual sitemaps
    sitemap_files = render_sitemap(link_groups)

    # render index
    render_index(sitemap_files)
    
    stop_time = Time.now
    puts "Sitemap stats: #{number_with_delimiter(SitemapGenerator::Sitemap.links.length)} links, " + ("%dm%02ds" % (stop_time - start_time).divmod(60)) if verbose
  end

  def render_sitemap(link_groups)
    sitemap_files = []
    link_groups.each_with_index do |links, index|
      buffer = ''
      xml = Builder::XmlMarkup.new(:target=>buffer)
      eval(open(SitemapGenerator.templates[:sitemap_xml]).read, binding)
      filename = File.join(RAILS_ROOT, "public/sitemap#{index+1}.xml.gz")
      Zlib::GzipWriter.open(filename) do |gz|
        gz.write buffer
      end
      sitemap_files << filename
      puts "+ #{filename}" if verbose
      puts "** Sitemap too big! The uncompressed size exceeds 10Mb" if (buffer.size > 10 * 1024 * 1024) && verbose
    end
    sitemap_files
  end

  def render_index(sitemap_files)
    buffer = ''
    xml = Builder::XmlMarkup.new(:target=>buffer)
    eval(open(SitemapGenerator.templates[:sitemap_index]).read, binding)
    filename = File.join(RAILS_ROOT, "public/sitemap_index.xml.gz")
    Zlib::GzipWriter.open(filename) do |gz|
      gz.write buffer
    end
    
    puts "+ #{filename}" if verbose
    puts "** Sitemap Index too big! The uncompressed size exceeds 10Mb" if (buffer.size > 10 * 1024 * 1024) && verbose
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
