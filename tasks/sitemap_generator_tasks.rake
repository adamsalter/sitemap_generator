require 'zlib'

namespace :sitemap do

  desc "Install a default config/sitemap.rb file"
  task :install do
    load File.expand_path(File.join(File.dirname(__FILE__), "..", "install.rb"))
  end

  desc "Delete all Sitemap files in public/ directory"
  task :clean do
    sitemap_files = Dir[File.join(RAILS_ROOT, 'public/sitemap*.xml.gz')]
    FileUtils.rm sitemap_files
  end

  desc "Create Sitemap XML files in public/ directory"
  desc "Create Sitemap XML files in public/ directory (set SILENT=true for no output)"
  task :refresh => ['sitemap:create'] do
    ping_search_engines("sitemap_index.xml.gz")
  end

  desc "Create Sitemap XML files (don't ping search engines)"
  task 'refresh:no_ping' => ['sitemap:create'] do
  end

  task :create => [:environment] do
    include SitemapGenerator::Helper
    include ActionView::Helpers::NumberHelper

    start_time = Time.now

    # update links from config/sitemap.rb
    load_sitemap_rb

    raise(ArgumentError, "Default hostname not defined") if SitemapGenerator::Sitemap.default_host.blank?

    links_grps = SitemapGenerator::Sitemap.links.in_groups_of(50000, false)
    raise(ArgumentError, "TOO MANY LINKS!! I really thought 2,500,000,000 links would be enough for anybody!") if links_grps.length > 50000

    Rake::Task['sitemap:clean'].invoke

    # render individual sitemaps
    sitemap_files = []
    xml_sitemap_template = File.join(File.dirname(__FILE__), '../templates/xml_sitemap.builder')
    links_grps.each_with_index do |links, index|
      buffer = ''
      xml = Builder::XmlMarkup.new(:target=>buffer)
      eval(open(xml_sitemap_template).read, binding)
      filename = File.join(RAILS_ROOT, "public/sitemap#{index+1}.xml.gz")
      Zlib::GzipWriter.open(filename) do |gz|
        gz.write buffer
      end
      puts "+ #{filename}" unless ENV['SILENT'].present?
      puts "** Sitemap too big! The uncompressed size exceeds 10Mb" if (buffer.size > 10 * 1024 * 1024) && ENV['SILENT'].blank?
      sitemap_files << filename
    end

    # render index
    sitemap_index_template = File.join(File.dirname(__FILE__), '../templates/sitemap_index.builder')
    buffer = ''
    xml = Builder::XmlMarkup.new(:target=>buffer)
    eval(open(sitemap_index_template).read, binding)
    filename = File.join(RAILS_ROOT, "public/sitemap_index.xml.gz")
    Zlib::GzipWriter.open(filename) do |gz|
      gz.write buffer
    end
    puts "+ #{filename}" unless ENV['SILENT'].present?
    puts "** Sitemap Index too big! The uncompressed size exceeds 10Mb" if (buffer.size > 10 * 1024 * 1024) && ENV['SILENT'].blank?

    stop_time = Time.now
    puts "Sitemap stats: #{number_with_delimiter(SitemapGenerator::Sitemap.links.length)} links, " + ("%dm%02ds" % (stop_time - start_time).divmod(60)) unless ENV['SILENT'].present?

  end
end
