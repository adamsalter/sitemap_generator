require "spec_helper"

describe "Sitemap Groups" do
  before :each do
    @sm = ::SitemapGenerator::LinkSet.new(:default_host => 'http://test.com')
  end                                                                       
  
  describe "sitemap filename" do
    before :each do
      FileUtils.rm_rf(SitemapGenerator.app.root + 'public/')
    end

    # it "should be changed" do
    #   @sm.create do    
    #     group(:filename => :sitemap_en) do
    #       debugger 
    #       add '/en'
    #     end
    #   end
    # 
    #   file_should_exist(SitemapGenerator.app.root + 'public/sitemap_index.xml.gz')
    #   file_should_exist(SitemapGenerator.app.root + 'public/sitemap_en1.xml.gz')
    #   file_should_exist(SitemapGenerator.app.root + 'public/sitemap1.xml.gz')
    # end        
  end
end