class AddStatusToReminds < ActiveRecord::Migration[5.0]
  def change
    add_column :reminds, :status, :integer
  end
end
