class RemovePlace < ActiveRecord::Migration[5.0]
  def up
    remove_column :weathers, :place
  end

  def down
    add_column :weathers, :place, :string
  end
end
