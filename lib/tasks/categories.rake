namespace :categories do
  desc "既存ユーザーにデフォルトカテゴリを作成"
  task create_defaults: :environment do
    puts "既存ユーザーにデフォルトカテゴリを作成中..."

    default_categories = [
      { name: 'カリキュラム学習', color: '#3B82F6' },
      { name: 'プログラミング', color: '#10B981' },
      { name: 'アプリ開発', color: '#F59E0B' },
      { name: '読書', color: '#8B5CF6' },
      { name: '動画視聴', color: '#06B6D4' },
      { name: 'イベント参加', color: '#EF4444' },
      { name: 'その他', color: '#6B7280' }
    ]

    users_count = 0
    categories_created = 0

    User.find_each do |user|
      # 既にカテゴリを持っているユーザーはスキップ
      next if user.categories.exists?

      default_categories.each do |attrs|
        category = user.categories.build(attrs)
        if category.save
          categories_created += 1
          puts "  ユーザー #{user.email} に「#{attrs[:name]}」カテゴリを作成"
        else
          puts "  エラー: ユーザー #{user.email} の「#{attrs[:name]}」カテゴリ作成に失敗 - #{category.errors.full_messages.join(', ')}"
        end
      end

      users_count += 1
    end

    puts "完了: #{users_count}人のユーザーに#{categories_created}個のカテゴリを作成しました"
  end
end