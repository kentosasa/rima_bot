class CreateReminds < ActiveRecord::Migration[5.0]
  def change
    create_table :reminds do |t|
      t.integer :group_id
      t.datetime :at
      t.boolean :activated
      t.boolean :reminded
      t.string :name
      t.text :body
      t.string :place
      t.datetime :datetime
      t.integer :scale

      t.string :type

      t.timestamps
    end
  end
end
