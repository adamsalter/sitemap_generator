require 'spec_helper'

describe "Templates class" do

  it "should provide method access to each template" do
    SitemapGenerator::Templates::FILES.each do |name, file|
      SitemapGenerator.templates.send(name).should_not be(nil)
      SitemapGenerator.templates.send(name).should == File.read(File.join(SitemapGenerator.root, 'templates', file))
    end
  end
  
  describe "templates" do
    before :each do
      SitemapGenerator.templates.sitemap_xml = nil
      File.stub!(:read).and_return('read file')
    end
    
    it "should only be read once" do
      File.should_receive(:read).once
      SitemapGenerator.templates.sitemap_xml
      SitemapGenerator.templates.sitemap_xml
    end    
  end
end