class AddEmailConfirmationToUsers < ActiveRecord::Migration[7.2]
  def change
    # ユーザー名フィールド追加
    add_column :users, :name, :string, null: false, default: ''
    
    # Devise confirmable用フィールド追加
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    add_column :users, :unconfirmed_email, :string
    
    # インデックス追加
    add_index :users, :confirmation_token, unique: true
    
    # 既存ユーザーを確認済みに設定（後方互換性のため）
    reversible do |dir|
      dir.up do
        # 既存ユーザーのnameにemailのローカル部分を設定
        execute <<-SQL
          UPDATE users 
          SET confirmed_at = NOW(), 
              name = SPLIT_PART(email, '@', 1)
          WHERE confirmed_at IS NULL;
        SQL
      end
    end
  end
end