# require 'simplecov'
# SimpleCov.start
require 'bundler/setup'
Bundler.require

require './spec/support/file_macros'
require './spec/support/xml_macros'
require 'webmock/rspec'

WebMock.disable_net_connect!

SitemapGenerator.verbose = false

RSpec.configure do |config|
  config.mock_with :mocha
  config.include(FileMacros)
  config.include(XmlMacros)
end
