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
    # 進行中のセッションがあるかチェック（開始モードの場合のみ）
    if params[:mode] == "start" && current_user.session_in_progress?
      redirect_to dashboard_path, alert: "既に進行中の学習セッションがあります"
      return
    end

    @session = current_user.sessions.build(session_params)
    @session.paused_seconds = 0

    # モードに応じて処理を分岐
    case params[:mode]
    when "start"
      # 開始モード：現在時刻で開始
      @session.started_at = Time.current
      success_message = "学習セッションを開始しました"
      redirect_path = dashboard_path
    when "record"
      # 記録モード：入力された日時で記録
      date = params[:session][:date]
      start_time = params[:session][:start_time]
      end_date = params[:session][:end_date]
      end_time = params[:session][:end_time]

      if date.present? && start_time.present?
        @session.started_at = Time.zone.parse("#{date} #{start_time}")
      end
      if end_date.present? && end_time.present?
        @session.ended_at = Time.zone.parse("#{end_date} #{end_time}")
      end

      success_message = "学習セッションを記録しました"
      redirect_path = study_sessions_path
    else
      # デフォルト：開始モード
      @session.started_at = Time.current
      success_message = "学習セッションを開始しました"
      redirect_path = dashboard_path
    end

    if @session.save
      redirect_to redirect_path, notice: success_message
    else
      redirect_to redirect_path, alert: "学習セッションの作成に失敗しました"
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
