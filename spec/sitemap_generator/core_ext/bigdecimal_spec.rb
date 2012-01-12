require 'spec_helper'
require 'bigdecimal'

describe SitemapGenerator::BigDecimal do
  describe "to_yaml" do
    it "should serialize correctly" do
      SitemapGenerator::BigDecimal.new('100000.30020320320000000000000000000000000000001').to_yaml.should =~ /^--- 100000\.30020320320000000000000000000000000000001\n/
      SitemapGenerator::BigDecimal.new('Infinity').to_yaml.should =~ /^--- \.Inf\n/
      SitemapGenerator::BigDecimal.new('NaN').to_yaml.should =~ /^--- \.NaN\n/
      SitemapGenerator::BigDecimal.new('-Infinity').to_yaml.should =~ /^--- -\.Inf\n/
    end
  end

  describe "to_d" do
    it "should convert correctly" do
      bd = SitemapGenerator::BigDecimal.new '10'
      bd.to_d.should == bd
    end
  end
end
