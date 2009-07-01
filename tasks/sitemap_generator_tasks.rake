require 'zlib'

namespace :sitemap do

  desc "install a default config/sitemap.rb file"
  task :install do
    load File.expand_path(File.join(File.dirname(__FILE__), "..", "install.rb"))  
  end

  desc "Regenerate Google Sitemap files in public/ directory"
  task :refresh => :environment do
    include SitemapPlugin::Helper
  
    # update links from config/sitemap.rb
    load_sitemap_rb
  
    raise(ArgumentError, "Default hostname not defined") unless SitemapPlugin::Sitemap.default_host.present?

    links_grps = SitemapPlugin::Sitemap.links.in_groups_of(50000, false)
  
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
      puts "+ #{filename}"
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
    puts "+ #{filename}"
  
    ping_search_engines("sitemap_index.xml.gz")
  
  end
end