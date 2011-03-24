require 'spec_helper'

describe SitemapGenerator::Application do
  before :each do
    @app = SitemapGenerator::Application.new
  end
  
  context "rails3?" do
    tests = {
      :nil => false,
      '2.3.11' => false,
      '3.0.1' => true,
      '3.0.11' => true
    }
    
    it "should identify the rails version correctly" do
      tests.each do |version, result|
        Rails.expects(:version).returns(version)
        @app.rails3?.should == result
      end
    end
  end
end
