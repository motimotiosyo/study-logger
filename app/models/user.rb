class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable  # メール認証機能追加

  has_many :sessions, dependent: :destroy
  has_many :categories, dependent: :destroy

  # バリデーション
  validates :name, presence: true, length: { minimum: 1, maximum: 50 }
  validates :target_hours, numericality: { greater_than: 0 }, allow_nil: true

  # デフォルト目標時間を1000時間に設定
  after_initialize :set_default_target_hours
  # 🔥 変更：メール認証完了時にカテゴリ作成
  after_update :create_categories_on_confirmation, if: :saved_change_to_confirmed_at?

  # 累計学習時間（秒）
  def total_study_seconds
    sessions.sum(&:actual_seconds)
  end

  # 累計学習時間（時間）
  def total_study_hours
    total_study_seconds / 3600.0
  end

  # 目標達成率（パーセント）
  def achievement_rate
    return 0 if target_hours.nil? || target_hours.zero?
    ((total_study_hours / target_hours) * 100).round(1)
  end

  # 期間別の学習時間取得
  def study_time_for_period(period)
    case period
    when :today
      sessions.where(started_at: Date.current.all_day).sum(&:actual_seconds)
    when :this_week
      sessions.where(started_at: Date.current.beginning_of_week..Date.current.end_of_week).sum(&:actual_seconds)
    when :this_month
      sessions.where(started_at: Date.current.beginning_of_month..Date.current.end_of_month).sum(&:actual_seconds)
    when :all_time
      total_study_seconds
    else
      0
    end
  end

  # 現在進行中のセッション
  def current_session
    sessions.where(ended_at: nil).last
  end

  # セッション進行中かどうか
  def session_in_progress?
    current_session.present?
  end

  # カテゴリ別学習時間統計
  def category_stats
    categories.includes(:sessions).map do |category|
      {
        category: category,
        total_seconds: category.total_study_seconds,
        this_week_seconds: category.this_week_seconds
      }
    end.sort_by { |stat| -stat[:total_seconds] }
  end

  # 表示用名前（メール認証後はname、未認証時はemail）
  def display_name
    name.present? ? name : email.split('@').first
  end

  private

  def set_default_target_hours
    self.target_hours ||= 1000
  end

  # 🔥 メール認証完了時にデフォルトカテゴリを作成
  def create_categories_on_confirmation
    return if categories.exists? # 既にカテゴリがある場合はスキップ

    default_categories = [
      { name: "カリキュラム学習", color: "#3B82F6" },
      { name: "プログラミング", color: "#10B981" },
      { name: "アプリ開発", color: "#F59E0B" },
      { name: "読書", color: "#8B5CF6" },
      { name: "動画視聴", color: "#06B6D4" },
      { name: "イベント参加", color: "#EF4444" },
      { name: "その他", color: "#6B7280" }
    ]

    default_categories.each do |attrs|
      categories.create!(attrs)
    end
  end
end