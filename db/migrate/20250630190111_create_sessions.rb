class CreateSessions < ActiveRecord::Migration[7.2]
  def change
    create_table :sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :started_at
      t.datetime :ended_at
      t.integer :paused_seconds
      t.datetime :paused_at

      t.timestamps
    end
  end
end
