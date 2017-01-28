class AddCommentToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :schedule_id, :integer, index: true
    add_column :reminds, :candidate_body, :text
  end
end
