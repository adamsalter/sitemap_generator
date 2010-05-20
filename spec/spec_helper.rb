ENV["RAILS_ENV"] ||= 'test'
ENV['BUNDLE_GEMFILE'] = File.join(File.dirname(__FILE__), 'mock_rails3_gem', 'Gemfile')

sitemap_rails =
  case ENV["SITEMAP_RAILS"]
  when 'rails3'
    "mock_rails3_gem"
  when 'gem', 'plugin'
    "mock_app_#{ENV["SITEMAP_RAILS"]}"
  else
    "mock_app_gem"
  end

# Load the app's Rakefile so we know everything is being loaded correctly
load(File.join(File.dirname(__FILE__), sitemap_rails, 'Rakefile'))

require 'rubygems'
begin
  case RUBY_VERSION
  when '1.9.1'
    require 'ruby-debug19'
  else
    require 'ruby-debug'
  end
rescue Exception => e
end

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

Spec::Runner.configure do |config|
  config.include(FileMacros)
end

module Helpers
  extend self

  # Invoke and then re-enable the task so it can be called multiple times
  #
  # <tt>task</tt> task symbol/string
  def invoke_task(task)
    Rake.send(:verbose, false)
    Rake::Task[task.to_s].invoke
    Rake::Task[task.to_s].reenable
  end
end