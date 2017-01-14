class CreateCandidateUserRelations < ActiveRecord::Migration[5.0]
  def change
    create_table :candidate_user_relations do |t|
      t.integer :candidate_id
      t.integer :user_id
      t.boolean :attend

      t.timestamps
    end
  end
end
