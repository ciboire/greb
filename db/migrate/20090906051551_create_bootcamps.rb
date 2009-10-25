class CreateBootcamps < ActiveRecord::Migration
  def self.up
    create_table :bootcamps do |t|
      t.string :city
      t.string :message
      t.string :date
      t.string :time
      t.string :button_id
      t.decimal :price
      t.integer :max_students
      t.boolean :space_available
      t.boolean :registration_open
      t.timestamps
    end
  end
    
  def self.down
    drop_table :bootcamps
  end
end
