ENV['RAILS_ENV'] = 'test'
ENV['RAILS_ROOT'] ||= File.join(File.dirname(__FILE__), 'mock_app')

require File.expand_path(File.join(ENV['RAILS_ROOT'], 'config', 'environment.rb'))

require 'spec'
require 'spec/rails'
