class RemoveDate < ActiveRecord::Migration[5.0]
  def up
    remove_column :candidates, :date
  end

  def down
    add_column :candidates, :date, :datetime
  end
end
