namespace :users do
  desc "30分以上未認証のユーザーを削除"
  task cleanup_unconfirmed: :environment do
    cutoff_time = 30.minutes.ago
    
    # 30分以上前に作成された未認証ユーザーを取得
    unconfirmed_users = User.where(confirmed_at: nil)
                           .where('created_at < ?', cutoff_time)
    
    count = unconfirmed_users.count
    
    if count > 0
      puts "#{count}件の未認証ユーザーを削除します..."
      unconfirmed_users.find_each do |user|
        puts "削除: #{user.email} (作成日時: #{user.created_at})"
        user.destroy
      end
      puts "削除完了: #{count}件"
    else
      puts "削除対象の未認証ユーザーはありません"
    end
  end
  
  desc "未認証ユーザーの状況確認"
  task check_unconfirmed: :environment do
    total_users = User.count
    unconfirmed_users = User.where(confirmed_at: nil)
    old_unconfirmed = unconfirmed_users.where('created_at < ?', 30.minutes.ago)
    
    puts "=== 未認証ユーザー状況 ==="
    puts "総ユーザー数: #{total_users}"
    puts "未認証ユーザー数: #{unconfirmed_users.count}"
    puts "30分以上経過した未認証ユーザー: #{old_unconfirmed.count}"
    
    if old_unconfirmed.any?
      puts "\n削除対象:"
      old_unconfirmed.each do |user|
        puts "- #{user.email} (#{time_ago_in_words(user.created_at)}前)"
      end
    end
  end
end