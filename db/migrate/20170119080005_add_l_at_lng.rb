class AddLAtLng < ActiveRecord::Migration[5.0]
  def change
    add_column :weathers, :latitude, :float
    add_column :weathers, :longitude, :float
  end
end
