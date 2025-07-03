class DashboardController < ApplicationController
  def index
    # @current_session = current_user.current_session ← この行を以下に変更
    @current_session = current_user.sessions.includes(:category).where(ended_at: nil).first

    # 残りのコードはそのまま
    @recent_sessions = current_user.sessions.includes(:category).order(started_at: :desc).limit(5)

    # 期間別学習時間
    @today_seconds = current_user.study_time_for_period(:today)
    @week_seconds = current_user.study_time_for_period(:this_week)
    @month_seconds = current_user.study_time_for_period(:this_month)
    @total_seconds = current_user.study_time_for_period(:all_time)

    # 目標達成率
    @achievement_rate = current_user.achievement_rate
  end

  def update_target_hours
    if current_user.update(target_hours_params)
      redirect_to dashboard_path, notice: "目標時間を更新しました"
    else
      redirect_to dashboard_path, alert: "目標時間の更新に失敗しました"
    end
  end

  private

  def target_hours_params
    params.require(:user).permit(:target_hours)
  end

  # 秒を時間:分形式に変換するヘルパー
  def format_duration(seconds)
    total_minutes = seconds / 60
    hours = total_minutes / 60
    minutes = total_minutes % 60
    "#{hours}時間#{minutes}分"
  end
  helper_method :format_duration
end
