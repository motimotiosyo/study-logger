class CategoriesController < ApplicationController
  before_action :set_category, only: [ :edit, :update, :destroy ]
  before_action :check_ownership, only: [ :edit, :update, :destroy ]

  def index
    @categories = current_user.categories.order(created_at: :asc)
    @category_stats = current_user.category_stats
  end

  def new
    @category = current_user.categories.build
    @available_colors = Category::DEFAULT_COLORS
  end

  def create
    @category = current_user.categories.build(category_params)

    if @category.save
      redirect_to categories_path, notice: "カテゴリ「#{@category.name}」を作成しました"
    else
      # バリデーションエラー時はリダイレクトしてフラッシュメッセージで表示
      error_messages = @category.errors.full_messages.join("、")
      redirect_to categories_path, alert: "カテゴリの作成に失敗しました: #{error_messages}"
    end
  end

  def edit
    @available_colors = Category::DEFAULT_COLORS
  end

  def update
    # デフォルトカテゴリの編集を防止
    if @category.default_category?
      redirect_to categories_path, alert: "デフォルトカテゴリは編集できません"
      return
    end

    if @category.update(category_params)
      redirect_to categories_path, notice: "カテゴリ「#{@category.name}」を更新しました"
    else
      # バリデーションエラー時はリダイレクトしてフラッシュメッセージで表示
      error_messages = @category.errors.full_messages.join("、")
      redirect_to categories_path, alert: "カテゴリの更新に失敗しました: #{error_messages}"
    end
  end

  def destroy
    # デフォルトカテゴリの削除を防止（二重チェック）
    if @category.default_category?
      redirect_to categories_path, alert: "デフォルトカテゴリは削除できません"
      return
    end

    category_name = @category.name
    sessions_count = @category.sessions.count

    if sessions_count > 0
      # セッションがある場合は「未分類」に移動
      @category.sessions.update_all(category_id: nil)
      @category.destroy
      redirect_to categories_path,
                 notice: "カテゴリ「#{category_name}」を削除しました。#{sessions_count}個のセッションは「未分類」に移動されました。"
    else
      # セッションがない場合は直接削除
      @category.destroy
      redirect_to categories_path, notice: "カテゴリ「#{category_name}」を削除しました"
    end
  rescue => e
    redirect_to categories_path, alert: "カテゴリの削除に失敗しました: #{e.message}"
  end

  private

  def set_category
    @category = current_user.categories.find(params[:id])
  end

  def check_ownership
    # set_categoryで既にcurrent_user.categoriesから取得しているので、追加チェック不要
  end

  def category_params
    params.require(:category).permit(:name, :color)
  end
end
