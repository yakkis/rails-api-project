# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'application#not_found'

  scope :api, constraints: { format: :json }, defaults: { format: :json } do
    resources :games, only: %i[index show create] do
      resources :throws, only: %i[create]
    end
  end
end
