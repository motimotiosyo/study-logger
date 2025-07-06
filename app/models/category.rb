class Category < ApplicationRecord
  belongs_to :user
  has_many :sessions, dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :color, presence: true, format: { with: /\A#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})\z/, message: "must be a valid hex color" }

  # デフォルトカラーパレット
  DEFAULT_COLORS = [
    "#3B82F6", # Blue
    "#10B981", # Green
    "#F59E0B", # Yellow
    "#EF4444", # Red
    "#8B5CF6", # Purple
    "#06B6D4", # Cyan
    "#F97316", # Orange
    "#84CC16"  # Lime
  ].freeze

  # 学習時間を計算（秒）
  def total_study_seconds
    sessions.sum(&:actual_seconds)
  end

  # 学習時間を計算（時間）
  def total_study_hours
    total_study_seconds / 3600.0
  end

  # このカテゴリでの今週の学習時間
  def this_week_seconds
    sessions.where(started_at: 1.week.ago..Time.current).sum(&:actual_seconds)
  end

  # このカテゴリでの今月の学習時間（秒）
  def this_month_seconds
    sessions.where(started_at: Time.current.beginning_of_month..Time.current.end_of_month).sum(&:actual_seconds)
  end

  # 🆕 デフォルトカテゴリかどうか判定
  def default_category?
    is_default == true
  end

  # 🆕 カスタムカテゴリかどうか判定
  def custom_category?
    !default_category?
  end

  # 🆕 削除可能かどうか判定
  def deletable?
    custom_category?
  end

  # 🆕 セッション数を取得
  def sessions_count
    sessions.count
  end
end
