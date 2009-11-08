require 'rake/testtask'
require 'find'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "sitemap_generator"
    s.summary = %Q{Generate 'enterprise-class' Sitemaps for your Rails site using a simple 'Rails Routes'-like DSL and a single Rake task}
    s.description = %Q{Install as a plugin or Gem to easily generate ['enterprise-class'][enterprise_class] Google Sitemaps for your Rails site, using a simple 'Rails Routes'-like DSL and a single rake task.}
    s.email = "adam.salter@codebright.net "
    s.homepage = "http://github.com/adamsalter/sitemap_generator"
    s.authors = ["Adam Salter"]
    s.files =  FileList["[A-Z]*", "{bin,lib,rails,templates,tasks}/**/*"]
    # s is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

desc 'Default: run unit tests.'
task :default => :test

desc 'Test.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

