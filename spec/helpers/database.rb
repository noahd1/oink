require 'active_record'
require 'mongo_mapper'

def setup_memory_database
  ActiveRecord::Base.establish_connection(
    :adapter  => 'sqlite3',
    :database => ':memory:'
  )

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

  MongoMapper.connection = Mongo::Connection.new('localhost')
  MongoMapper.database = "oink"
end