# encoding: UTF-8
require 'spec_helper'
require 'google/cloud/storage'

describe SitemapGenerator::GoogleStorageAdapter do
  subject(:adapter) { SitemapGenerator::GoogleStorageAdapter.new(options) }

  let(:options) { { credentials: 'abc', project_id: 'project_id', bucket: 'bucket' } }

  describe 'write' do
    let(:location) { SitemapGenerator::SitemapLocation.new }

    it 'writes the raw data to a file and then uploads that file to Google Storage' do
      bucket = double(:bucket)
      storage = double(:storage)
      bucket_resource = double(:bucket_resource)
      expect(Google::Cloud::Storage).to receive(:new).with(credentials: 'abc', project_id: 'project_id').and_return(storage)
      expect(storage).to receive(:bucket).with('bucket').and_return(bucket_resource)
      expect(location).to receive(:path_in_public).and_return('path_in_public')
      expect(location).to receive(:path).and_return('path')
      expect(bucket_resource).to receive(:create_file).with('path', 'path_in_public', acl: 'public').and_return(nil)
      expect_any_instance_of(SitemapGenerator::FileAdapter).to receive(:write).with(location, 'raw_data')
      adapter.write(location, 'raw_data')
    end
  end

  describe '.new' do
    it "doesn't modify the original options" do
      adapter
      expect(options.size).to be(3)
    end
  end
end
