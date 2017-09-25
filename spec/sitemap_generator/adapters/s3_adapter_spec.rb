# encoding: UTF-8
require 'spec_helper'
require 'fog-aws'

describe SitemapGenerator::S3Adapter do
  let(:location) do
    SitemapGenerator::SitemapLocation.new(
      :namer => SitemapGenerator::SimpleNamer.new(:sitemap),
      :public_path => 'tmp/',
      :sitemaps_path => 'test/',
      :host => 'http://example.com/')
  end
  let(:directory) do
    double('directory',
      :files => double('files', :create => nil)
    )
  end
  let(:directories) do
    double('directories',
      :directories =>
        double('directory class',
          :new => directory
        )
    )
  end

  before do
    SitemapGenerator::S3Adapter # eager load
    expect(Fog::Storage).to receive(:new).and_return(directories)
  end

  it 'should create the file in S3 with a single operation' do
    subject.write(location, 'payload')
  end
end
