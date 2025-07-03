class AddCategoryToSessions < ActiveRecord::Migration[7.2]
  def change
    add_reference :sessions, :category, null: true, foreign_key: true
    # categoryは必須ではない（既存セッションもあるため）
  end
end