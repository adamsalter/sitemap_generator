# require 'simplecov'
# SimpleCov.start
require 'bundler/setup'
Bundler.require

require './spec/support/file_macros'
require './spec/support/xml_macros'
require 'webmock/rspec'
require 'byebug'

WebMock.disable_net_connect!

SitemapGenerator.verbose = false

RSpec.configure do |config|
  config.include(FileMacros)
  config.include(XmlMacros)
end
