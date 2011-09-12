require 'spec_helper'

class Holder
  class << self
    attr_accessor :executed
  end
end

def with_max_links(num)
  original = SitemapGenerator::MAX_SITEMAP_LINKS
  SitemapGenerator.const_set(:MAX_SITEMAP_LINKS, num)
  yield
  SitemapGenerator.const_set(:MAX_SITEMAP_LINKS, original)
end

describe "SitemapGenerator" do

  describe "reset!" do
    before :each do
      SitemapGenerator::Sitemap.default_host # Force initialization of the LinkSet
    end

    it "should set a new LinkSet instance" do
      first = SitemapGenerator::Sitemap.instance_variable_get(:@link_set)
      first.should be_a(SitemapGenerator::LinkSet)
      SitemapGenerator::Sitemap.reset!
      second = SitemapGenerator::Sitemap.instance_variable_get(:@link_set)
      second.should be_a(SitemapGenerator::LinkSet)
      first.should_not be(second)
    end
  end

  describe "root" do
    it "should be set to the root of the gem" do
      SitemapGenerator.root.should == File.expand_path('../../../' , __FILE__)
    end
  end

  # describe "clean task" do
  #   before :each do
  #     FileUtils.touch(rails_path('public/sitemap_index.xml.gz'))
  #     Helpers.invoke_task('sitemap:clean')
  #   end
  #
  #   it "should delete the sitemaps" do
  #     file_should_not_exist(rails_path('public/sitemap_index.xml.gz'))
  #   end
  # end

  # describe "fresh install" do
  #   before :each do
  #     delete_sitemap_file_from_rails_app
  #     Helpers.invoke_task('sitemap:install')
  #   end
  #
  #   it "should create config/sitemap.rb" do
  #     file_should_exist(rails_path('config/sitemap.rb'))
  #   end
  #
  #   it "should create config/sitemap.rb matching template" do
  #     sitemap_template = SitemapGenerator.templates.template_path(:sitemap_sample)
  #     files_should_be_identical(rails_path('config/sitemap.rb'), sitemap_template)
  #   end
  # end

  # describe "install multiple times" do
  #   before :each do
  #     copy_sitemap_file_to_rails_app(:deprecated)
  #     Helpers.invoke_task('sitemap:install')
  #   end
  #
  #   it "should not overwrite config/sitemap.rb" do
  #     sitemap_file = File.join(SitemapGenerator.root, 'spec/files/sitemap.deprecated.rb')
  #     files_should_be_identical(sitemap_file, rails_path('config/sitemap.rb'))
  #   end
  # end

  [:deprecated, :create].each do |extension|
    describe "generate sitemap" do
      before :all do
        SitemapGenerator::Sitemap.reset!
        clean_sitemap_files_from_rails_app
        copy_sitemap_file_to_rails_app(extension)
        with_max_links(10) { execute_sitemap_config }
      end

      it "should create sitemaps" do
        file_should_exist(rails_path('public/sitemap_index.xml.gz'))
        file_should_exist(rails_path('public/sitemap1.xml.gz'))
        file_should_exist(rails_path('public/sitemap2.xml.gz'))
        file_should_not_exist(rails_path('public/sitemap3.xml.gz'))
      end

      it "should have 14 links" do
        SitemapGenerator::Sitemap.link_count.should == 14
      end

      it "index XML should validate" do
        gzipped_xml_file_should_validate_against_schema rails_path('public/sitemap_index.xml.gz'), 'siteindex'
      end

      it "sitemap XML should validate" do
        gzipped_xml_file_should_validate_against_schema rails_path('public/sitemap1.xml.gz'), 'sitemap'
        gzipped_xml_file_should_validate_against_schema rails_path('public/sitemap2.xml.gz'), 'sitemap'
      end

      it "index XML should not have excess whitespace" do
        gzipped_xml_file_should_have_minimal_whitespace rails_path('public/sitemap_index.xml.gz')
      end

      it "sitemap XML should not have excess whitespace" do
        gzipped_xml_file_should_have_minimal_whitespace rails_path('public/sitemap1.xml.gz')
      end
    end
  end

  describe "sitemap with groups" do
    before :all do
      SitemapGenerator::Sitemap.reset!
      clean_sitemap_files_from_rails_app
      copy_sitemap_file_to_rails_app(:groups)
      with_max_links(2) { execute_sitemap_config }
      @expected = %w[
        public/en/xxx1.xml.gz
        public/fr/abc3.xml.gz
        public/fr/abc4.xml.gz
        public/fr/new_sitemaps_index.xml.gz
        public/fr/new_sitemaps1.xml.gz
        public/fr/new_sitemaps2.xml.gz
        public/fr/new_sitemaps3.xml.gz
        public/fr/new_sitemaps4.xml.gz]
      @sitemaps = (@expected - %w[public/fr/new_sitemaps_index.xml.gz])
    end

    it "should create sitemaps" do
      @expected.each { |file| file_should_exist(rails_path(file)) }
      file_should_not_exist(rails_path('public/fr/new_sitemaps5.xml.gz'))
      file_should_not_exist(rails_path('public/en/xxx2.xml.gz'))
      file_should_not_exist(rails_path('public/fr/abc5.xml.gz'))
    end

    it "should have 14 links" do
      SitemapGenerator::Sitemap.link_count.should == 13
    end

    it "index XML should validate" do
      gzipped_xml_file_should_validate_against_schema rails_path('public/fr/new_sitemaps_index.xml.gz'), 'siteindex'
    end

    it "index XML should not have excess whitespace" do
      gzipped_xml_file_should_have_minimal_whitespace rails_path('public/fr/new_sitemaps_index.xml.gz')
    end

    it "sitemaps XML should validate" do
      @sitemaps.each { |file| gzipped_xml_file_should_validate_against_schema(rails_path(file), 'sitemap') }
    end

    it "sitemap XML should not have excess whitespace" do
      @sitemaps.each { |file| gzipped_xml_file_should_have_minimal_whitespace(rails_path(file)) }
    end
  end

  describe "sitemap path" do
    before :each do
      clean_sitemap_files_from_rails_app
      ::SitemapGenerator::Sitemap.reset!
      ::SitemapGenerator::Sitemap.default_host = 'http://test.local'
      ::SitemapGenerator::Sitemap.filename = 'sitemap'
    end

    it "should allow changing of the filename" do
      ::SitemapGenerator::Sitemap.create(:filename => :geo_sitemap) do
        add '/goerss', :geo => { :format => 'georss' }
        add '/kml', :geo => { :format => 'kml' }
      end
      file_should_exist(rails_path('public/geo_sitemap_index.xml.gz'))
      file_should_exist(rails_path('public/geo_sitemap1.xml.gz'))
    end

    it "should support setting a sitemap path" do
      directory_should_not_exist(rails_path('public/sitemaps/'))

      sm = ::SitemapGenerator::Sitemap
      sm.sitemaps_path = 'sitemaps/'
      sm.create do
        add '/'
        add '/another'
      end

      file_should_exist(rails_path('public/sitemaps/sitemap_index.xml.gz'))
      file_should_exist(rails_path('public/sitemaps/sitemap1.xml.gz'))
    end

    it "should support setting a deeply nested sitemap path" do
      directory_should_not_exist(rails_path('public/sitemaps/deep/directory'))

      sm = ::SitemapGenerator::Sitemap
      sm.sitemaps_path = 'sitemaps/deep/directory/'
      sm.create do
        add '/'
        add '/another'
        add '/yet-another'
      end

      file_should_exist(rails_path('public/sitemaps/deep/directory/sitemap_index.xml.gz'))
      file_should_exist(rails_path('public/sitemaps/deep/directory/sitemap1.xml.gz'))
    end
  end

  describe "external dependencies" do
    describe "rails" do
      before :each do
        @rails = Rails
        Object.send(:remove_const, :Rails)
      end

      after :each do
        Object::Rails = @rails
      end

      it "should work outside of Rails" do
        defined?(Rails).should be_nil
        lambda { ::SitemapGenerator::LinkSet.new }.should_not raise_exception
      end
    end
  end

  protected

  #
  # Helpers
  #

  def rails_path(file)
    SitemapGenerator.app.root + file
  end

  def copy_sitemap_file_to_rails_app(extension)
    FileUtils.cp(File.join(SitemapGenerator.root, "spec/files/sitemap.#{extension}.rb"), SitemapGenerator.app.root + 'config/sitemap.rb')
  end

  def delete_sitemap_file_from_rails_app
    FileUtils.remove(SitemapGenerator.app.root + 'config/sitemap.rb')
  rescue
    nil
  end

  def clean_sitemap_files_from_rails_app
    FileUtils.rm_rf(rails_path('public/'))
    FileUtils.mkdir_p(rails_path('public/'))
  end

  # Better would be to just invoke the environment task and use
  # the interpreter.
  def execute_sitemap_config
   SitemapGenerator::Interpreter.run
  end
end
