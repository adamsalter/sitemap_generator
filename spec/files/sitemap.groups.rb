SitemapGenerator::Sitemap.default_host = "http://www.example.com"
SitemapGenerator::Sitemap.create(
    :include_root => true, :include_index => true,
    :filename => :new_sitemaps, :sitemaps_path => 'fr/') do

  add('/one', :priority => 0.7, :changefreq => 'daily')

  # Test a new location and filename and sitemaps host
  group(:sitemaps_path => 'en/', :filename => :xxx,
      :sitemaps_host => "http://newhost.com") do

    add '/two'
    add '/three'
  end

  # Test a namer
  group(:sitemaps_namer => SitemapGenerator::SitemapNamer.new(:abc, :start => 3)) do
    add '/four'
    add '/five'
    add '/six'
  end

  add '/seven'

  # This should be in a file of its own
  group(:sitemaps_host => "http://exceptional.com") do
    add '/eight'
    add '/nine'
  end

  add '/ten'

  # This should have no effect.  Already added default links.
  group(:include_root => true, :include_index => true) {}

  add "/merchant_path", :host => "https://www.merchanthost.com"
end
