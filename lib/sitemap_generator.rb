require 'sitemap_generator/link'
require 'sitemap_generator/link_set'
require 'sitemap_generator/link_set/builder'
require 'sitemap_generator/helper'
require 'sitemap_generator/templates'

module SitemapGenerator
  silence_warnings do
    VERSION = File.read(File.dirname(__FILE__) + "/../VERSION").strip
    MAX_ENTRIES = 50_000
    Sitemap = SitemapGenerator::LinkSet::Builder.new
  end
  
  class << self
    attr_accessor :root, :templates, :template, :x
  end

  self.root = File.expand_path(File.join(File.dirname(__FILE__), '../'))
  self.templates = SitemapGenerator::Templates.new(self.root)
end