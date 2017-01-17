class AddCandidateUserRelationsToAnswer < ActiveRecord::Migration[5.0]
  def change
    add_column :candidate_user_relations, :attendance, :integer
  end
end
