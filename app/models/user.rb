class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :sessions, dependent: :destroy

  # バリデーションを緩める（一時的）
  validates :target_hours, numericality: { greater_than: 0 }, allow_nil: true

  # デフォルト目標時間を1000時間に設定
  after_initialize :set_default_target_hours

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

  private

  def set_default_target_hours
    self.target_hours ||= 1000
  end
end
