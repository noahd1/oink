ActiveRecord::Schema.define(:version => 1) do
  
  create_table "pigs", :force => true do |t|
    t.integer "pen_id"
    t.string "name"
    t.boolean "smells"
  end
  
  create_table "pens", :force => true do |t|
    t.string "location"
  end
  
end