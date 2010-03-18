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
        write_file(filename, buffer)
        show_progress("Sitemap", filename, buffer) if verbose
      end
      sitemap_files
    end

    # Render sitemap index file.
    def render_index(verbose = true)
      buffer = ''
      xml = Builder::XmlMarkup.new(:target => buffer)
      eval(open(SitemapGenerator.templates[:sitemap_index]).read, binding)
      filename = File.join(RAILS_ROOT, "public/sitemap_index.xml.gz")
      write_file(filename, buffer)
      show_progress("Sitemap Index", filename, buffer) if verbose
    end

    # Commit buffer to gzipped file.
    def write_file(name, buffer)
      Zlib::GzipWriter.open(name) { |gz| gz.write buffer }
    end

    # Report progress line.
    def show_progress(title, filename, buffer)
      puts "+ #{filename}"
      puts "** #{title} too big! The uncompressed size exceeds 10Mb" if buffer.size > 10.megabytes
    end

    # Copy templates/sitemap.rb to config if not there yet.
    def install_sitemap_rb
      if File.exist?(File.join(RAILS_ROOT, 'config/sitemap.rb'))
        puts "already exists: config/sitemap.rb, file not copied"
      else
        FileUtils.cp(SitemapGenerator.templates[:sitemap_sample], File.join(RAILS_ROOT, 'config/sitemap.rb'))
        puts "created: config/sitemap.rb"
      end
    end

    # Remove config/sitemap.rb if exists.
    def uninstall_sitemap_rb
      if File.exist?(File.join(RAILS_ROOT, 'config/sitemap.rb'))
        File.rm(File.join(RAILS_ROOT, 'config/sitemap.rb'))
      end
    end
  end
end
