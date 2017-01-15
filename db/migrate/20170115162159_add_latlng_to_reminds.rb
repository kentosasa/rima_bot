class AddLatlngToReminds < ActiveRecord::Migration[5.0]
  def change
    add_column :reminds, :latitude, :float
    add_column :reminds, :longitude, :float
    add_column :reminds, :address, :string
  end
end
