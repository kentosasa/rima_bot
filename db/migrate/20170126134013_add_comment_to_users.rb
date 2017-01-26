class AddCommentToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :comment, :string
    add_column :users, :answer, :text
    add_column :users, :schedule_id, :integer, index: true
    add_index :users, :schedule_id

    add_column :reminds, :candidate_body, :text

    drop_table :candidate_user_relations
    drop_table :candidates

  end
end
