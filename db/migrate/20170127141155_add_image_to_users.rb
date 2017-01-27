class AddImageToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :groups, :image, :string
  end
end
