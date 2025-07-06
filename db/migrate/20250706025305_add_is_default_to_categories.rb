class AddIsDefaultToCategories < ActiveRecord::Migration[7.2]
  def change
    add_column :categories, :is_default, :boolean, default: false, null: false
    add_index :categories, :is_default

    # 既存のデフォルトカテゴリを is_default = true に設定
    reversible do |dir|
      dir.up do
        Category.reset_column_information
        default_category_names = [
          'カリキュラム学習',
          'プログラミング', 
          'アプリ開発',
          '読書',
          '動画視聴',
          'イベント参加',
          'その他'
        ]
        
        Category.where(name: default_category_names).update_all(is_default: true)
      end
    end
  end
end