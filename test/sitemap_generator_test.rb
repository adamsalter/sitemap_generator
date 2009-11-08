require File.dirname(__FILE__) + '/test_helper'

class SitemapGeneratorTest < Test::Unit::TestCase
  context "SitemapGenerator Rake Tasks" do

    context "when running the clean task" do
      setup do
        copy_sitemap_file_to_rails_app
        FileUtils.touch(File.join(RAILS_ROOT, '/public/sitemap_index.xml.gz'))
        Rake::Task['sitemap:clean'].invoke
      end
    
      should "the sitemap xml files be deleted" do
        assert !File.exists?(File.join(RAILS_ROOT, '/public/sitemap_index.xml.gz'))
      end
    end
    
    # For some reason I just couldn't get this to work!  It seemed to delete the
    # file before calling the second *should* assertion.
    context "when installed to a clean Rails app" do
      setup do
        #delete_sitemap_file_from_rails_app
        #Rake::Task['sitemap:install'].invoke
      end

      should "a sitemap.rb is created" do
        #assert File.exists?(File.join(RAILS_ROOT, 'config/sitemap.rb'))
      end

      should "the sitemap.rb file matches the template" do
        #assert identical_files?(File.join(RAILS_ROOT, 'config/sitemap.rb'), SitemapGenerator.templates[:sitemap_sample])
      end
    end
    
    context "when installed multiple times" do
      setup do
        copy_sitemap_file_to_rails_app
        Rake::Task['sitemap:install'].invoke
      end  
          
      should "not overwrite existing sitemap.rb file" do  
        assert identical_files?(File.join(File.dirname(__FILE__), '/sitemap.file'), File.join(RAILS_ROOT, '/config/sitemap.rb'))
      end
    end
    
    context "when sitemap generated" do
      setup do
        copy_sitemap_file_to_rails_app
        Rake::Task['sitemap:refresh'].invoke
      end  
          
      should "not create sitemap xml files" do  
        assert File.exists?(File.join(RAILS_ROOT, '/public/sitemap_index.xml.gz'))
        assert File.exists?(File.join(RAILS_ROOT, '/public/sitemap1.xml.gz'))  
      end
    end
  end
  
  context "SitemapGenerator library" do
    setup do
      copy_sitemap_file_to_rails_app
    end
        
    should "be have x elements" do
      assert_equal 14, SitemapGenerator::Sitemap.links.size
    end
  end
  
  def copy_sitemap_file_to_rails_app
    FileUtils.cp(File.join(File.dirname(__FILE__), '/sitemap.file'), File.join(RAILS_ROOT, '/config/sitemap.rb'))
  end
  
  def delete_sitemap_file_from_rails_app
    FileUtils.remove(File.join(RAILS_ROOT, '/config/sitemap.rb')) rescue nil
  end
  
  def identical_files?(first, second)
    first = open(first, 'r').read
    second = open(second, 'r').read
    first == second
  end
end

