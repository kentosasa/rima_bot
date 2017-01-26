class AddCaracterToGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :groups, :character, :integer, default: 0
  end
end
