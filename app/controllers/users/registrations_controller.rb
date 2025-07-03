class Users::RegistrationsController < Devise::RegistrationsController
  # POST /users
  def create
    build_resource(sign_up_params)

    if resource.save
      # 🔥 新規登録成功時：確認メール送信メッセージでログイン画面へ
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :signed_up_but_unconfirmed
        respond_with resource, location: new_session_path(resource_name)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  protected

  # 🔥 新規登録後はログイン画面にリダイレクト
  def after_sign_up_path_for(resource)
    new_user_session_path
  end

  # 🔥 未認証ユーザーの新規登録後はログイン画面へ
  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end
end
