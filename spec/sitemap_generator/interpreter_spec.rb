require 'spec_helper'
require 'sitemap_generator/interpreter'

describe SitemapGenerator::Interpreter do
  # The interpreter doesn't have the URL helpers included for some reason, so it
  # fails when adding links.  That messes up later specs unless we reset the sitemap object.
  after :all do
    SitemapGenerator::Sitemap = SitemapGenerator::LinkSet.new
  end

  it "should find the config file if Rails.root doesn't end in a slash" do
    rails_root = Rails.root.to_s.sub(/\/$/, '')
    Rails.expects(:root).returns(rails_root).at_least_once
    lambda { SitemapGenerator::Interpreter.run }.should_not raise_exception(Errno::ENOENT)
  end
end