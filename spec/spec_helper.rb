ENV["RAILS_ENV"] ||= 'test'

sitemap_rails = ENV["SITEMAP_RAILS"] ? "mock_app_#{ENV["SITEMAP_RAILS"]}" : 'mock_app_gem'

# Boot the environment
require File.join(File.dirname(__FILE__), sitemap_rails, 'config', 'boot')

# Load the app's Rakefile so we know everything is being loaded correctly
load(File.join(File.dirname(__FILE__), sitemap_rails, 'Rakefile'))

require 'ruby-debug'
# debugger

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

Spec::Runner.configure do |config|
  config.include(FileMacros)
end