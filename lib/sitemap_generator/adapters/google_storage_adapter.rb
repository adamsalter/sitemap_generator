if !defined?(Google::Cloud::Storage)
  raise "Error: `Google::Cloud::Storage` is not defined.\n\n"\
        "Please `require 'google/cloud/storage'` - or another library that defines this class."
end

module SitemapGenerator
  # Class for uploading sitemaps to a Google Storage using google-cloud-storage gem.
  class GoogleStorageAdapter
    # Requires Google::Cloud::Storage to be defined.
    #
    # Options:
    #   :credentials [String] Path to the google service account keyfile.json
    #   :project_id [String] Google Accounts project_id where the storage bucket resides
    #   :bucket [String] Name of Google Storage Bucket where the file is to be uploaded

    # @param [Hash] opts Google::Cloud::Storage configuration options
    def initialize(opts = {})
      @credentials = opts[:keyfile] || ENV['GOOGLE_CLOUD_PROJECT']
      @project_id = opts[:project_id] || ENV['GOOGLE_APPLICATION_CREDENTIALS']
      @bucket = opts[:bucket]
    end

    # Call with a SitemapLocation and string data
    def write(location, raw_data)
      SitemapGenerator::FileAdapter.new.write(location, raw_data)

      storage = Google::Cloud::Storage.new(project_id: @project_id, credentials: @credentials)
      bucket = storage.bucket @bucket
      bucket.create_file location.path, location.path_in_public, acl: 'public'
    end
  end
end
