class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Deviseの認証を必須にする
  before_action :authenticate_user!
  # 🔥 追加：認証済みユーザーのメール認証確認
  before_action :ensure_user_confirmed!, if: :user_signed_in?
  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  def configure_permitted_parameters
    # 新規登録とアカウント更新でnameを許可
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name, :target_hours ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name, :target_hours ])
  end

  # 🔥 新規追加：メール未認証ユーザーを制限
  def ensure_user_confirmed!
    return if devise_controller? # Deviseのコントローラーはスキップ
    return if current_user.confirmed? # 認証済みはスキップ

    # 未認証ユーザーをサインアウトしてログイン画面にリダイレクト
    sign_out(current_user)
    redirect_to new_user_session_path, alert: "メールアドレスの確認が必要です。確認メールをご確認ください。"
  end
end
