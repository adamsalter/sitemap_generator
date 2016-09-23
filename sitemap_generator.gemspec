# encoding: utf-8

Gem::Specification.new do |s|
  s.name        = %q{sitemap_generator}
  s.version     = File.read('VERSION').chomp
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Karl Varga"]
  s.email       = %q{kjvarga@gmail.com}
  s.homepage    = %q{http://github.com/kjvarga/sitemap_generator}
  s.summary     = %q{Easily generate XML Sitemaps}
  s.description = %q{SitemapGenerator is a framework-agnostic XML Sitemap generator written in Ruby with automatic Rails integration.  It supports Video, News, Image, Geo, Mobile, PageMap and Alternate Links sitemap extensions and includes Rake tasks for managing your sitemaps, as well as many other great features.}
  s.license     = 'MIT'
  s.add_development_dependency 'mocha', '~> 0.10.0'
  s.add_development_dependency 'nokogiri', '=1.15.10'
  s.add_development_dependency 'rspec', '~>2.8'
  s.add_dependency 'builder', '~> 3.0'
  s.test_files  = Dir.glob(['spec/**/*']) - Dir.glob(['spec/mock_*', 'spec/mock_*/**/*'])
  s.files       = Dir.glob(["[A-Z]*", "{lib,rails,templates}/**/*"]) - Dir.glob('*.orig')

  s.post_install_message = <<-EOM
NOTE: SitemapGenerator 4.x uses a new file naming scheme which is more standards-compliant.
If you're upgrading from 3.x, please see the release note in the README:

https://github.com/kjvarga/sitemap_generator#important-changes-in-version-4

The simple answer is that your index file is now called sitemap.xml.gz
and not sitemap_index.xml.gz, but please take a look and see what else has changed.
EOM
end
