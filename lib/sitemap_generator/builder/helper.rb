module SitemapGenerator
  module Builder
    module Helper

      def w3c_date(date)
         date.utc.strftime("%Y-%m-%dT%H:%M:%S+00:00")
      end
    end
  end
end