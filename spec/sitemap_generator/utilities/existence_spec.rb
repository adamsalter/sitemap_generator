require 'spec_helper'

class EmptyTrue
  def empty?() true; end
end

class EmptyFalse
  def empty?() false; end
end

BLANK = [ EmptyTrue.new, nil, false, '', '   ', "  \n\t  \r ", [], {} ]
NOT   = [ EmptyFalse.new, Object.new, true, 0, 1, 'a', [nil], { nil => 0 } ]

describe Object do
  let(:utils) { SitemapGenerator::Utilities }

  it "should define blankness" do
    BLANK.each { |v| utils.blank?(v).should be true }
    NOT.each   { |v| utils.blank?(v).should be false }
  end

  it "should define presence" do
    BLANK.each { |v| utils.present?(v).should be false }
    NOT.each   { |v| utils.present?(v).should be true }
  end
end
