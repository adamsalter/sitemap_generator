SitemapGenerator
================

This plugin enables Google Sitemaps to be easily generated for a Rails site as a rake task. (and it _actually_ works)

SiteMaps are generally not required to be dynamic, so if you need to refresh your Sitemaps regularly you can set the rake task up as a cron job.

Raison d'être
-------

I was dissatisfied with any of the current Rails sitemap plugins that I found. So I decided I would write my own. ;)

I say "it actually works" because in the process of creating this plugin I tried about 6 different plugins, none of which (IMHO) worked in a natural 'railsy' way. Your mileage may differ of course.

Installation
=======

1.Install plugin as normal

    ./script/plugin install git://github.com/adamsalter/sitemap_generator-plugin.git

2.Installation will create a 'config/sitemap.rb' file which will contain your logic for generation of the Sitemap files. Explanation of syntax for this file is contained in the file itself. (If you want to recreate this file manually run `rake sitemap:install`)

3.Run `rake sitemap:refresh` as needed to create sitemap files. This will also ping all the major search engines.

4.Add the following to your robots.txt file. The &lt;sitemap_index_location> should be the complete URL to the Sitemap index, such as: http://www.example.org/sitemap_index.xml.gz

    Sitemap: <sitemap_index_location>

Notes
=======

- only tested/working on Rails 2.3.2, no guarantees made for any other versions of Rails.
- currently only supports one sitemap index file, which can contain 50,000 sitemap files which can each contain 50,000 urls, so plugin only supports up to 2,500,000,000 urls. I personally have no need of support for more urls, but plugin could be improved to support this.

Copyright (c) 2009 Adam @ [Codebright.net][cb], released under the MIT license

[cb]:http://codebright.net