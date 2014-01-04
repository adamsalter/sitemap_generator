require 'spec_helper'

describe "SitemapGenerator::FileAdapter" do
  let(:location) { SitemapGenerator::SitemapLocation.new }
  let(:adapter)  { SitemapGenerator::FileAdapter.new }

  describe "write" do
    it "should gzip contents if filename ends in .gz" do
      adapter.expects(:gzip).once
      location.stubs(:filename).returns('sitemap.xml.gz')
      adapter.write(location, 'data')
    end

    it "should not gzip contents if filename does not end in .gz" do
      adapter.expects(:plain).once
      location.stubs(:filename).returns('sitemap.xml')
      adapter.write(location, 'data')
    end
  end
end