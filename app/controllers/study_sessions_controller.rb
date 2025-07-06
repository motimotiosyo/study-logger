class StudySessionsController < ApplicationController
  before_action :set_session, only: [ :edit, :update, :destroy, :start, :pause, :resume, :finish ]
  before_action :set_categories, only: [ :new, :create, :edit, :update ]

  def index
    @sessions = current_user.sessions.includes(:category).order(started_at: :desc)
    @categories = current_user.categories.order(:name)
  end

  def new
    # 進行中のセッションがあるかチェック
    if current_user.session_in_progress?
      redirect_to dashboard_path, alert: "既に進行中の学習セッションがあります"
      return
    end

    @session = current_user.sessions.build
  end

  def create
    # 進行中のセッションがあるかチェック
    if current_user.session_in_progress?
      redirect_to dashboard_path, alert: "既に進行中の学習セッションがあります"
      return
    end

    @session = current_user.sessions.build(session_params)
    @session.paused_seconds = 0
    @session.started_at = Time.current  # 現在時刻で開始

    if @session.save
      redirect_to dashboard_path, notice: "学習セッションを開始しました"
    else
      redirect_to dashboard_path, alert: "学習セッションの開始に失敗しました"
    end
  end

  def edit
  end

  def update
    if @session.update(session_params)
      redirect_to study_sessions_path, notice: "学習セッションを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @session.destroy
    redirect_to study_sessions_path, notice: "学習セッションを削除しました"
  end

  # セッション開始（既存セッションの再開始用）
  def start
    if @session.start!
      redirect_to dashboard_path, notice: "学習セッションを開始しました"
    else
      redirect_to dashboard_path, alert: "学習セッションの開始に失敗しました"
    end
  end

  # セッション一時停止
  def pause
    if @session.pause!
      redirect_to dashboard_path, notice: "学習を一時停止しました"
    else
      redirect_to dashboard_path, alert: "学習の一時停止に失敗しました"
    end
  end

  # セッション再開
  def resume
    if @session.resume!
      redirect_to dashboard_path, notice: "学習を再開しました"
    else
      redirect_to dashboard_path, alert: "学習の再開に失敗しました"
    end
  end

  # セッション終了
  def finish
    if @session.finish!
      redirect_to dashboard_path, notice: "学習を終了しました"
    else
      redirect_to dashboard_path, alert: "学習の終了に失敗しました"
    end
  end

  private

  def set_session
    @session = current_user.sessions.find(params[:id])
  end

  def set_categories
    @categories = current_user.categories.order(:name)
  end

  def session_params
    params.require(:session).permit(:notes, :category_id)
  end
end
