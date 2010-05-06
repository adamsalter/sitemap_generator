require 'spec_helper'

describe "SitemapGenerator" do
  
  context "clean task" do
    before :all do
      copy_sitemap_file_to_rails_app
      FileUtils.touch(rails_path('/public/sitemap_index.xml.gz'))
      Rake::Task['sitemap:clean'].invoke
    end
  
    it "should delete the sitemaps" do
      file_should_not_exist(rails_path('/public/sitemap_index.xml.gz'))
    end
  end
  
  context "fresh install" do
    before :all do
      delete_sitemap_file_from_rails_app
      Rake::Task['sitemap:install'].invoke
    end
  
    it "should create config/sitemap.rb" do
      file_should_exist(rails_path('config/sitemap.rb'))
    end
  
    it "should create config/sitemap.rb matching template" do
      sitemap_template = SitemapGenerator.templates.template_path(:sitemap_sample)
      files_should_be_identical(rails_path('config/sitemap.rb'), sitemap_template)
    end
  
    context "install multiple times" do
      before :all do
        copy_sitemap_file_to_rails_app
        Rake::Task['sitemap:install'].invoke
      end  
        
      it "should not overwrite config/sitemap.rb" do
        sitemap_file = File.join(File.dirname(__FILE__), '/sitemap.file')
        files_should_be_identical(sitemap_file, rails_path('/config/sitemap.rb'))
      end
    end
  end  
  
  context "generate sitemap" do
    before :each do
      Rake::Task['sitemap:refresh:no_ping'].invoke
    end  
        
    it "should create sitemaps" do  
      file_should_exist(rails_path('/public/sitemap_index.xml.gz'))
      file_should_exist(rails_path('/public/sitemap1.xml.gz'))
    end
    
    it "should have 14 links" do
      SitemapGenerator::Sitemap.link_count.should == 14
    end    
  end
   
  protected
    
  #
  # Helpers
  #
  
  def rails_path(file)
    File.join(::Rails.root, file)
  end
  
  def copy_sitemap_file_to_rails_app
    FileUtils.cp(File.join(File.dirname(__FILE__), '/sitemap.file'), File.join(::Rails.root, '/config/sitemap.rb'))
  end
  
  def delete_sitemap_file_from_rails_app
    FileUtils.remove(File.join(::Rails.root, '/config/sitemap.rb')) rescue nil
  end
end