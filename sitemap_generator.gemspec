# encoding: utf-8

Gem::Specification.new do |s|
  s.name        = %q{sitemap_generator}
  s.version     = File.read('VERSION').chomp
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Karl Varga", "Adam Salter"]
  s.email       = %q{kjvarga@gmail.com}
  s.homepage    = %q{http://github.com/kjvarga/sitemap_generator}
  s.summary     = %q{Easily generate enterprise class Sitemaps for your Rails site using a familiar Rails Routes-like DSL}
  s.description = %q{SitemapGenerator is a Rails gem that makes it easy to generate enterprise-class Sitemaps readable by all search engines.  Generated Sitemaps adhere to the Sitemap protocol specification.  When you generate new Sitemaps, SitemapGenerator can automatically ping the major search engines (including Google, Yahoo and Bing) to notify them.  SitemapGenerator includes rake tasks to easily manage your sitemaps.}
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'nokogiri'
  s.add_development_dependency 'rspec'
  s.add_dependency 'builder'
  s.test_files  = Dir.glob(['spec/**/*']) - Dir.glob(['spec/mock_*', 'spec/mock_*/**/*'])
  s.files       = Dir.glob(["[A-Z]*", "{lib,rails,templates}/**/*"]) - Dir.glob('*.orig')
end
