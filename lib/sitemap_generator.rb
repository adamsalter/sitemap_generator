require 'sitemap_generator/builder'
require 'sitemap_generator/sitemap_namer'
require 'sitemap_generator/link_set'
require 'sitemap_generator/templates'
require 'sitemap_generator/utilities'
require 'sitemap_generator/application'
require 'active_support/core_ext/numeric'

module SitemapGenerator
  SitemapError = Class.new(StandardError)
  SitemapFullError = Class.new(SitemapError)
  SitemapFinalizedError = Class.new(SitemapError)

  silence_warnings do
    VERSION = File.read(File.dirname(__FILE__) + "/../VERSION").strip
    MAX_SITEMAP_FILES    = 50_000        # max sitemap links per index file
    MAX_SITEMAP_LINKS    = 50_000        # max links per sitemap
    MAX_SITEMAP_IMAGES   = 1_000         # max images per url
    MAX_SITEMAP_FILESIZE = 10.megabytes  # bytes

    # Lazy-initialize the LinkSet instance
    Sitemap = (Class.new do
      def method_missing(*args, &block)
        (@link_set ||= LinkSet.new).send(*args, &block)
      end
    end).new
  end

  class << self
    attr_accessor :root, :app, :templates
  end

  self.root = File.expand_path(File.join(File.dirname(__FILE__), '../'))
  self.templates = SitemapGenerator::Templates.new(self.root)
  self.app = SitemapGenerator::Application.new
end

require 'sitemap_generator/railtie' if SitemapGenerator.app.rails3?
