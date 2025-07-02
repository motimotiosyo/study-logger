Rails.application.routes.draw do
  devise_for :users

  # ルートをダッシュボードに設定
  root "dashboard#index"

  # ダッシュボード
  get "dashboard", to: "dashboard#index"

  # セッション管理
  resources :sessions, except: [ :show ] do
    member do
      patch :start
      patch :pause
      patch :resume
      patch :finish
    end
  end

  # ユーザープロフィール
  resource :profile, only: [ :show, :edit, :update ]

  # ヘルスチェック
  get "up" => "rails/health#show", as: :rails_health_check
end
