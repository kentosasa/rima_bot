class SourceId < ActiveRecord::Migration[5.0]
  def change
    add_column :groups, :source_id, :string
  end
end
