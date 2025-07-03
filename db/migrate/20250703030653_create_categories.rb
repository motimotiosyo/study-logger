class CreateCategories < ActiveRecord::Migration[7.2]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string :color, default: '#3B82F6' # デフォルトは青色
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    # ユーザーごとのカテゴリ名は一意にする
    add_index :categories, [:user_id, :name], unique: true
  end
end