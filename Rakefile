require 'rake/testtask'
require 'find'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "sitemap_generator"
    s.summary = %Q{This plugin enables 'enterprise-class' Google Sitemaps to be easily generated for a Rails site as a rake task}
    s.description = %Q{This plugin enables 'enterprise-class' Google Sitemaps to be easily generated for a Rails site as a rake task}
    s.email = "adam.salter@codebright.net "
    s.homepage = "http://github.com/adamsalter/sitemap_generator-plugin"
    s.authors = ["Adam Salter"]
    s.files =  FileList["[A-Z]*", "{bin,lib,rails,templates,tasks}/**/*"]
    # s is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
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

