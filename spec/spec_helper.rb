require "bundler/setup"
Bundler.require
require 'rspec/autorun'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

SitemapGenerator.verbose = false

RSpec.configure do |config|
  config.mock_with :mocha
  config.include(FileMacros)
  config.include(XmlMacros)

  # Pass :focus option to +describe+ or +it+ to run that spec only
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
end
