class AddHashToRemind < ActiveRecord::Migration[5.0]
  def change
    add_column :reminds, :uid, :string, index: true
  end
end
