require 'rake'
require 'rake/rdoctask'
require 'rubygems'
gem 'rspec', '1.3.0'
require 'spec/rake/spectask'
gem 'nokogiri'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "sitemap_generator"
    gem.summary = %Q{Easily generate enterprise class Sitemaps for your Rails site using a familiar Rails Routes-like DSL}
    gem.description = %Q{A Rails 3-compatible gem/plugin to generate enterprise-class Sitemaps using a familiar Rails Routes-like DSL.  Sitemaps are readable by all search engines and adhere to the Sitemap protocol specification.  Automatically pings search engines to notify them of new sitemaps (including Google, Yahoo and Bing).  Provides rake tasks to easily manage your sitemaps.  Supports image sitemaps and handles millions of links.}
    gem.email = "kjvarga@gmail.com"
    gem.homepage = "http://github.com/kjvarga/sitemap_generator"
    gem.authors = ["Adam Salter", "Karl Varga"]
    gem.files =  FileList["[A-Z]*", "{bin,lib,rails,templates,tasks}/**/*"]
    gem.test_files = []
    gem.add_development_dependency "rspec"
    gem.add_development_dependency "nokogiri"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

#
# Helper methods
#
module Helpers
  extend self

  # Return a full local path to path fragment <tt>path</tt>
  def local_path(path)
    File.join(File.dirname(__FILE__), path)
  end

  # Copy all of the local files into <tt>path</tt> after completely cleaning it
  def prepare_path(path)
    rm_rf path
    mkdir_p path
    cp_r(FileList["[A-Z]*", "{bin,lib,rails,templates,tasks}"], path)
  end
end

#
# Tasks
#
task :default => :test

namespace :test do
  task :gem => ['test:prepare:gem', 'multi_spec']
  task :plugin => ['test:prepare:plugin', 'multi_spec']
  task :rails3 => ['test:prepare:rails3', 'multi_spec']

  task :multi_spec do
    Rake::Task['spec'].invoke
    Rake::Task['spec'].reenable
  end

  namespace :prepare do
    task :gem do
      ENV["SITEMAP_RAILS"] = 'gem'
      Helpers.prepare_path(Helpers.local_path('spec/mock_app_gem/vendor/gems/sitemap_generator-1.2.3'))
      rm_rf(Helpers.local_path('spec/mock_app_gem/public/sitemap*'))
    end

    task :plugin do
      ENV["SITEMAP_RAILS"] = 'plugin'
      Helpers.prepare_path(Helpers.local_path('spec/mock_app_plugin/vendor/plugins/sitemap_generator-1.2.3'))
      rm_rf(Helpers.local_path('spec/mock_app_plugin/public/sitemap*'))
    end

    task :rails3 do
      ENV["SITEMAP_RAILS"] = 'rails3'
      rm_rf(Helpers.local_path('spec/mock_rails3_gem/public/sitemap*'))
    end
  end
end

desc "Release a new patch version"
task :release_new_version do
  Rake::Task['version:bump:patch'].invoke
  Rake::Task['github:release'].invoke
  Rake::Task['git:release'].invoke
  Rake::Task['gemcutter:release'].invoke
end

desc "Run tests as a gem install"
task :test => ['test:gem']

Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end
task :spec => :check_dependencies

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

desc 'Generate documentation'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'SitemapGenerator'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('lib/**/*.rb')
end