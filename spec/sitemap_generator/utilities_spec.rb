require 'spec_helper'

describe SitemapGenerator::Utilities do

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
        SitemapGenerator::Utilities.rails3?.should == result
      end
    end
  end
end