require 'machinist/active_record'
require 'sham'

Sham.title { Time.now.to_i }
Content.blueprint do
  title
end

module Blueprint
  def self.seed
    14.times do |i|
      content = Content.make(:title => "Link #{i}")
    end
  end
end