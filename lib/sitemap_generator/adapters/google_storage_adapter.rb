if !defined?(Google::Cloud::Storage)
  raise "Error: `Google::Cloud::Storage` is not defined.\n\n"\
        "Please `require 'google/cloud/storage'` - or another library that defines this class."
end

module SitemapGenerator
  # Class for uploading sitemaps to a Google Storage supported endpoint.
  class GoogleStorageAdapter
    # Requires Google::Cloud::Storage to be defined.
    #
    # @param [Hash] opts Fog configuration options
    # @option :credentials [Hash] Path to the google service account keyfile.json
    # @option :project_id [String] Google Accounts project_id where the storage bucket resides
    # @option :bucket [String] Name of Google Storage Bucket where the file is to be uploaded
    def initialize(opts = {})
      @credentials = opts[:keyfile] || ENV['']
      @project_id = opts[:project_id] || ENV['']
      @bucket = opts[:bucket] || ENV['']
    end

    # Call with a SitemapLocation and string data
    def write(location, raw_data)
      SitemapGenerator::FileAdapter.new.write(location, raw_data)

      storage   = Google::Cloud::Storage.new(project_id: @project_id, credentials: @credentials)
      bucket = storage.bucket @bucket
      bucket.create_file location.path, location.path_in_public, acl: 'public'
    end
  end
end
