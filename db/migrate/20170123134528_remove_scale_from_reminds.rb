class RemoveScaleFromReminds < ActiveRecord::Migration[5.0]
  def change
    remove_column :reminds, :scale
  end
end
