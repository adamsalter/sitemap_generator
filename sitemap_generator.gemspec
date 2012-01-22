# encoding: utf-8

Gem::Specification.new do |s|
  s.name        = %q{sitemap_generator}
  s.version     = File.read('VERSION').chomp
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Karl Varga", "Adam Salter"]
  s.email       = %q{kjvarga@gmail.com}
  s.homepage    = %q{http://github.com/kjvarga/sitemap_generator}
  s.summary     = %q{Easily generate XML Sitemaps}
  s.description = %q{SitemapGenerator is an XML Sitemap generator written in Ruby with automatic Rails integration.  It supports Video, News, Image and Geo sitemaps and includes Rake tasks for managing your sitemaps.}
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'nokogiri'
  s.add_development_dependency 'rspec'
  s.add_dependency 'builder'
  s.test_files  = Dir.glob(['spec/**/*']) - Dir.glob(['spec/mock_*', 'spec/mock_*/**/*'])
  s.files       = Dir.glob(["[A-Z]*", "{lib,rails,templates}/**/*"]) - Dir.glob('*.orig')
end
