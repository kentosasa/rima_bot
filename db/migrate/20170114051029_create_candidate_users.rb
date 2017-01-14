class CreateCandidateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :candidate_users do |t|
      t.integer :candidate_id
      t.integer :user_id
      t.boolean :attend

      t.timestamps
    end
  end
end
