require 'spec_helper'
require 'sitemap_generator/core_ext/object/blank'

class EmptyTrue
  def empty?() true; end
end

class EmptyFalse
  def empty?() false; end
end

BLANK = [ EmptyTrue.new, nil, false, '', '   ', "  \n\t  \r ", [], {} ]
NOT   = [ EmptyFalse.new, Object.new, true, 0, 1, 'a', [nil], { nil => 0 } ]

describe Object do
  it "should define blankness" do
    BLANK.each { |v| v.blank?.should be_true }
    NOT.each   { |v| v.blank?.should be_false }
  end

  it "should define presence" do
    BLANK.each { |v| v.present?.should be_false }
    NOT.each   { |v| v.present?.should be_true }

    BLANK.each { |v| v.presence.should be_nil }
    NOT.each   { |v| v.presence.should be(v)  }
  end
end
