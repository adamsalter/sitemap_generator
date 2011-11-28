require 'spec_helper'
require 'sitemap_generator/interpreter'

describe SitemapGenerator::Interpreter do
  # The interpreter doesn't have the URL helpers included for some reason, so it
  # fails when adding links.  That messes up later specs unless we reset the sitemap object.
  after :all do
    SitemapGenerator::Sitemap.reset!
  end

  it "should find the config file if Rails.root doesn't end in a slash" do
    Rails = stub(:root => SitemapGenerator.app.root.to_s.sub(/\/$/, ''))
    # Rails.expects(:root).returns(rails_root).at_least_once
    lambda { SitemapGenerator::Interpreter.run }.should_not raise_exception(Errno::ENOENT)
  end

  it "should set the verbose option" do
    SitemapGenerator::Interpreter.any_instance.expects(:instance_eval)
    interpreter = SitemapGenerator::Interpreter.run(:verbose => true)
    interpreter.instance_variable_get(:@linkset).verbose.should be_true
  end
end
