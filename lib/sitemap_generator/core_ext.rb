<<<<<<< HEAD
Dir["#{File.dirname(__FILE__)}/core_ext/**/*.rb"].sort.each do |path|
  require path
end

=======
Dir["#{File.dirname(__FILE__)}/core_ext/*.rb"].sort.each do |path|
  require "sitemap_generator/core_ext/#{File.basename(path, '.rb')}"
end
>>>>>>> Remove Rails dependencies.  Move them in-app:
