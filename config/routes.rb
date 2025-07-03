Rails.application.routes.draw do
  # 🔥 カスタムregistrationsコントローラーを追加
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    confirmations: 'users/confirmations'
  }

  # ルートをダッシュボードに設定
  root "dashboard#index"

  # ダッシュボード
  get "dashboard", to: "dashboard#index"

  # 学習セッション管理（study_sessionsに変更）
  resources :study_sessions, except: [ :show ] do
    member do
      patch :start
      patch :pause
      patch :resume
      patch :finish
    end
  end

  # ユーザープロフィール
  resource :profile, only: [ :show, :edit, :update ]

  # 目標時間更新（ダッシュボード用）
  patch "update_target_hours", to: "dashboard#update_target_hours"

  # ヘルスチェック
  get "up" => "rails/health#show", as: :rails_health_check
end