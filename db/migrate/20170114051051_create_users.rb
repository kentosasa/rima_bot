class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :comment
      t.text :answer

      t.timestamps
    end
  end
end
