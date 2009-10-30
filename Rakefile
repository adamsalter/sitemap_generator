require 'rake/testtask'
require 'find'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "sitemap_generator"
    gem.summary = %Q{This plugin enables 'enterprise-class' Google Sitemaps to be easily generated for a Rails site as a rake task}
    gem.description = %Q{This plugin enables 'enterprise-class' Google Sitemaps to be easily generated for a Rails site as a rake task}
    gem.email = "adam@salter.net "
    gem.homepage = "http://github.com/adamsalter/sitemap_generator-plugin"
    gem.authors = ["Adam Salter"]
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end

rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

desc 'Default: run unit tests.'
task :default => :test

desc 'Test ActiveScaffold.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

