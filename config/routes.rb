Rails.application.routes.draw do
  resources :games do
    member do
      get :watch
    end
    resource :placements, only: :create
    resource :tile_swaps, only: :create
    resource :turn_passes, only: :create
  end
end
