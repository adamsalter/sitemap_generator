require 'spec_helper'

describe SitemapGenerator::Numeric do
  def numeric(size)
    SitemapGenerator::Numeric.new(size)
  end

  describe "bytes" do
    it "should define equality of different units" do
      relationships = {
        numeric(  1024).bytes     => numeric(  1).kilobyte,
        numeric(  1024).kilobytes => numeric(  1).megabyte,
        numeric(3584.0).kilobytes => numeric(3.5).megabytes,
        numeric(3584.0).megabytes => numeric(3.5).gigabytes,
        numeric(1).kilobyte ** 4  => numeric(  1).terabyte,
        numeric(1024).kilobytes + numeric(2).megabytes =>   numeric(3).megabytes,
        numeric(             2).gigabytes / 4 => numeric(512).megabytes,
        numeric(256).megabytes * 20 +numeric( 5).gigabytes => numeric(10).gigabytes,
        numeric(1).kilobyte ** 5 => numeric(1).petabyte,
        numeric(1).kilobyte ** 6 => numeric(1).exabyte
      }

      relationships.each do |left, right|
        left.should == right
      end
    end

    it "should represent units as bytes" do
      numeric(3).megabytes.should == 3145728
      numeric(3).megabyte .should == 3145728
      numeric(3).kilobytes.should == 3072
      numeric(3).kilobyte .should == 3072
      numeric(3).gigabytes.should == 3221225472
      numeric(3).gigabyte .should == 3221225472
      numeric(3).terabytes.should == 3298534883328
      numeric(3).terabyte .should == 3298534883328
      numeric(3).petabytes.should == 3377699720527872
      numeric(3).petabyte .should == 3377699720527872
      numeric(3).exabytes .should == 3458764513820540928
      numeric(3).exabyte  .should == 3458764513820540928
    end
  end
end
