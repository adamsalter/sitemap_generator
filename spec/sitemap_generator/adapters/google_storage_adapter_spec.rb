# encoding: UTF-8
require 'spec_helper'
require 'google/cloud/storage'

describe SitemapGenerator::GoogleStorageAdapter do
  let(:location) { SitemapGenerator::SitemapLocation.new }
  let(:options) { {:credentials=>nil, :project_id=>nil} }
  let(:google_bucket) { 'bucket' }
  let(:adapter)  { SitemapGenerator::GoogleStorageAdapter.new(options.merge(bucket: google_bucket)) }

  describe 'write' do
    it 'it writes the raw data to a file and then uploads that file to Google Storage' do
      bucket = double(:bucket)
      storage = double(:storage)
      bucket_resource = double(:bucket_resource)
      expect(Google::Cloud::Storage).to receive(:new).with(options).and_return(storage)
      expect(storage).to receive(:bucket).with('bucket').and_return(bucket_resource)
      expect(location).to receive(:path_in_public).and_return('path_in_public')
      expect(location).to receive(:path).and_return('path')
      expect(bucket_resource).to receive(:create_file).with('path', 'path_in_public', acl: 'public').and_return(nil)
      expect_any_instance_of(SitemapGenerator::FileAdapter).to receive(:write).with(location, 'raw_data')
      adapter.write(location, 'raw_data')
    end
  end
end
