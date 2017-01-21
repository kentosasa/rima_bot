class AddHashToGroup < ActiveRecord::Migration[5.0]
  def change
    add_column :groups, :uid, :string, index: true
  end
end
