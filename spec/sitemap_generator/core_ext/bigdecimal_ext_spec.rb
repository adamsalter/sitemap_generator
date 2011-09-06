require 'spec_helper'
require 'bigdecimal'
require 'sitemap_generator/core_ext/big_decimal/conversions'

describe BigDecimal do
  describe "to_yaml" do
    it "should serialize correctly" do
      BigDecimal.new('100000.30020320320000000000000000000000000000001').to_yaml.should == "--- 100000.30020320320000000000000000000000000000001\n"
      BigDecimal.new('Infinity').to_yaml.should == "--- .Inf\n"
      BigDecimal.new('NaN').to_yaml.should == "--- .NaN\n"
      BigDecimal.new('-Infinity').to_yaml.should == "--- -.Inf\n"
    end
  end

  describe "to_d" do
    it "should convert correctly" do
      bd = BigDecimal.new '10'
      bd.to_d.should == bd
    end
  end
end
