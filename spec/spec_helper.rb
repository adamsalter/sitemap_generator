ENV['RAILS_ENV'] = 'test'

# This is basically the contents of mock_app_gems's Rakefile
require File.join(File.dirname(__FILE__), 'mock_app_gem', 'config', 'boot')
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'tasks/rails'
require 'sitemap_generator/tasks'

# Testing
require 'shoulda'