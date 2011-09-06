require 'spec_helper'
require 'sitemap_generator/core_ext/numeric/bytes'

describe Numeric do
  describe "bytes" do
    it "should define equality of different units" do
      relationships = {
          1024.bytes     =>   1.kilobyte,
          1024.kilobytes =>   1.megabyte,
        3584.0.kilobytes => 3.5.megabytes,
        3584.0.megabytes => 3.5.gigabytes,
        1.kilobyte ** 4  =>   1.terabyte,
        1024.kilobytes + 2.megabytes =>   3.megabytes,
                     2.gigabytes / 4 => 512.megabytes,
        256.megabytes * 20 + 5.gigabytes => 10.gigabytes,
        1.kilobyte ** 5 => 1.petabyte,
        1.kilobyte ** 6 => 1.exabyte
      }

      relationships.each do |left, right|
        left.should == right
      end
    end

    it "should represent units as bytes" do
      3.megabytes.should == 3145728
      3.megabyte .should == 3145728
      3.kilobytes.should == 3072
      3.kilobyte .should == 3072
      3.gigabytes.should == 3221225472
      3.gigabyte .should == 3221225472
      3.terabytes.should == 3298534883328
      3.terabyte .should == 3298534883328
      3.petabytes.should == 3377699720527872
      3.petabyte .should == 3377699720527872
      3.exabytes .should == 3458764513820540928
      3.exabyte  .should == 3458764513820540928
    end
  end
end
