require File.dirname(__FILE__) + '/test_helper'

class SitemapGeneratorTest < Test::Unit::TestCase
  context "SitemapGenerator Rake Task" do
    setup do
      ::Rake::Task['sitemap:refresh'].invoke
    end
    
    should "fail if hostname not defined" do
    end
  end

  context "SitemapGenerator library" do
    should "be have x elements" do
      assert_equal SitemapGenerator::Sitemap.links.size, 14
    end
  end
end

