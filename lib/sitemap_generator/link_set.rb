require File.dirname(__FILE__) + '/helper'

module SitemapGenerator
  class LinkSet
    include SitemapGenerator::Helper

    attr_accessor :default_host, :yahoo_app_id, :links
    attr_accessor :sitemap_files

    def initialize
      self.links         = []
      self.sitemap_files = []
    end

    def default_host=(host)
      @default_host = host
      add_default_links
    end

    def add_default_links
      # Add default links
      @links << Link.generate('/', :lastmod => Time.now, :changefreq => 'always', :priority => 1.0)
      @links << Link.generate('/sitemap_index.xml.gz', :lastmod => Time.now, :changefreq => 'always', :priority => 1.0)
    end

    def add_links
      yield Mapper.new(self)
    end

    def add_link(link)
      @links << link
    end

    # Return groups with no more than maximum allowed links.
    def link_groups
      links.in_groups_of(SitemapGenerator::MAX_ENTRIES, false)
    end

    # Render individual sitemap files.
    def render_sitemaps(verbose = true)
      sitemap_files.clear
      link_groups.each_with_index do |links, index|
        buffer = ''
        xml = Builder::XmlMarkup.new(:target => buffer)
        eval(open(SitemapGenerator.templates[:sitemap_xml]).read, binding)
        filename = File.join(RAILS_ROOT, "public/sitemap#{index+1}.xml.gz")
        Zlib::GzipWriter.open(filename) do |gz|
          gz.write buffer
        end
        sitemap_files.push filename
        puts "+ #{filename}" if verbose
        puts "** Sitemap too big! The uncompressed size exceeds 10Mb" if (buffer.size > 10 * 1024 * 1024) && verbose
      end
      sitemap_files
    end

    # Render sitemap index file.
    def render_index(verbose = true)
      buffer = ''
      xml = Builder::XmlMarkup.new(:target => buffer)
      eval(open(SitemapGenerator.templates[:sitemap_index]).read, binding)
      filename = File.join(RAILS_ROOT, "public/sitemap_index.xml.gz")
      Zlib::GzipWriter.open(filename) do |gz|
        gz.write buffer
      end

      puts "+ #{filename}" if verbose
      puts "** Sitemap Index too big! The uncompressed size exceeds 10Mb" if (buffer.size > 10 * 1024 * 1024) && verbose
    end
  end
end
