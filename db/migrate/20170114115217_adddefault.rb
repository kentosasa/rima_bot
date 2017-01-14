class Adddefault < ActiveRecord::Migration[5.0]
  def change
    change_column :reminds, :activated, :boolean, :default => false
    change_column :reminds, :reminded, :boolean, :default => false
  end
end
