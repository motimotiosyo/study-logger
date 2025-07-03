class Users::ConfirmationsController < Devise::ConfirmationsController
  # GET /users/confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.errors.empty?
      # 🔥 認証成功後にデフォルトカテゴリを作成
      resource.create_categories_on_confirmation

      set_flash_message!(:notice, :confirmed)
      respond_with_navigational(resource) { redirect_to after_confirmation_path_for(resource_name, resource) }
    else
      respond_with_navigational(resource.errors, status: :unprocessable_entity) { render :new }
    end
  end

  protected

  # 認証後はログイン画面へ
  def after_confirmation_path_for(resource_name, resource)
    new_user_session_path
  end
end
