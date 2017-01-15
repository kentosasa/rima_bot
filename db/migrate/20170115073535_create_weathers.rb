class CreateWeathers < ActiveRecord::Migration[5.0]
  def change
    create_table :weathers do |t|
      t.string :place
      t.string :image
      t.string :forcast
      t.string :temp
      t.date :date

      t.timestamps
    end
  end
end
