require 'rake/testtask'
require 'find'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "sitemap_generator"
    s.summary = %Q{Generate 'enterprise-class' Sitemaps for your Rails site using a simple 'Rails Routes'-like DSL and a single Rake task}
    s.description = %Q{Install as a plugin or Gem to easily generate ['enterprise-class'][enterprise_class] Google Sitemaps for your Rails site, using a simple 'Rails Routes'-like DSL and a single rake task.}
    s.email = "kjvarga@gmail.com"
    s.homepage = "http://github.com/kjvarga/sitemap_generator"
    s.authors = ["Adam Salter", "Karl Varga"]
    s.files =  FileList["[A-Z]*", "{bin,lib,rails,templates,tasks}/**/*"]
    s.test_files = []
    # s is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

task :default => :test

desc "Run tests"
task :test do
  Rake::Task["test:prepare"].invoke
  Rake::Task["test:sitemap_generator"].invoke
end

namespace :test do
  desc "Copy sitemap_generator files to mock apps"
  task :prepare do
    %w(test/mock_app_gem/vendor/gems/sitemap_generator-1.2.3 test/mock_app_plugin/vendor/plugins/sitemap_generator).each do |path|
      rm_rf path
      mkdir_p path
      cp_r FileList["[A-Z]*", "{bin,lib,rails,templates,tasks}"], path
    end
  end

  Rake::TestTask.new(:sitemap_generator) do |t|
    t.libs << 'lib'
    t.pattern = 'test/**/*_test.rb'
    t.verbose = true
  end
end
