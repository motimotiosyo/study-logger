class Session < ApplicationRecord
  belongs_to :user
  
  # デフォルト値を設定
  after_initialize :set_defaults, if: :new_record?
  
  # バリデーションを緩める - started_atは必須だが、createアクションで設定
  validates :paused_seconds, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  # セッションの状態
  def status
    return :not_started if started_at.nil?
    return :paused if paused_at.present?
    return :completed if ended_at.present?
    :in_progress
  end
  
  # 実際の学習時間（秒）を計算
  def actual_seconds
    return 0 if started_at.nil?
    return 0 if ended_at.nil? && status != :in_progress
    
    end_time = ended_at || Time.current
    total_seconds = (end_time - started_at).to_i
    total_seconds - paused_seconds
  end
  
  # 実際の学習時間（分）
  def actual_minutes
    actual_seconds / 60
  end
  
  # 実際の学習時間（時間）
  def actual_hours
    actual_seconds / 3600.0
  end
  
  # 学習時間を時間:分形式で表示
  def formatted_duration
    total_minutes = actual_minutes
    hours = total_minutes / 60
    minutes = total_minutes % 60
    "#{hours}時間#{minutes}分"
  end
  
  # セッション開始
  def start!
    update!(started_at: Time.current) if started_at.nil?
  end
  
  # セッション一時停止
  def pause!
    return false unless status == :in_progress
    update!(paused_at: Time.current)
  end
  
  # セッション再開
  def resume!
    return false unless status == :paused
    paused_duration = Time.current - paused_at
    update!(
      paused_seconds: paused_seconds + paused_duration.to_i,
      paused_at: nil
    )
  end
  
  # セッション終了
  def finish!
    # 一時停止中なら再開してから終了
    resume! if status == :paused
    update!(ended_at: Time.current)
  end
  
  private
  
  def set_defaults
    self.paused_seconds ||= 0
  end
end