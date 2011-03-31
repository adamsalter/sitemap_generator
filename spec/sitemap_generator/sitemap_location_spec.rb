require 'spec_helper'

describe SitemapGenerator::SitemapLocation do
  it "should have defaults" do
    @l = SitemapGenerator::SitemapLocation.new
    @l.public_path.should == SitemapGenerator.app.root + 'public/'
  end
end