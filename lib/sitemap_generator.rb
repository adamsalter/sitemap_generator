require 'sitemap_generator/mapper'
require 'sitemap_generator/link'
require 'sitemap_generator/link_set'
require 'sitemap_generator/helper'

module SitemapGenerator
  class <<self
    attr_accessor :root, :templates
  end
  self.root = File.expand_path(File.join(File.dirname(__FILE__), '../'))
  self.templates = {
    :sitemap_index => File.join(self.root, 'templates/sitemap_index.builder'),
    :sitemap_xml   => File.join(self.root, 'templates/xml_sitemap.builder'),
    :sitemap_sample => File.join(self.root, 'templates/sitemap.rb'),
  }
  
  Sitemap = LinkSet.new
end
  
