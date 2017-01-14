class CreateCandidates < ActiveRecord::Migration[5.0]
  def change
    create_table :candidates do |t|
      t.datetime :date
      t.integer :schedule_id

      t.timestamps
    end
  end
end
