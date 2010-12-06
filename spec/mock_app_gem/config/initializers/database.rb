# Define the schema and models dynamically
ActiveRecord::Schema.define(:version => 1) do
  create_table "contents" do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
end

class Content < ActiveRecord::Base
  validates_presence_of :title
end

if Content.count == 0
  (1..10).each do |i|
    Content.create!(:title => "content #{i}")
  end
end