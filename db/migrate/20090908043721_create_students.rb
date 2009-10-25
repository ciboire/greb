class CreateStudents < ActiveRecord::Migration
  def self.up
    create_table :students do |t|
      t.integer :bootcamp_id
      t.string :tx_token
      t.boolean :tx_accepted
      t.string :name
      t.string :email

      t.timestamps
    end
  end

  def self.down
    drop_table :students
  end
end
