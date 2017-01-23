class AddStatusToReminds < ActiveRecord::Migration[5.0]
  def change
    add_column :reminds, :status, :integer
    remove_column :reminds, :activated
    remove_column :reminds, :notified
  end
end
