Rails.application.routes.draw do
  resources :games do
    member do
      get :watch
    end
    resource :placements
    resource :tile_swaps
    resource :turn_passes
  end
end
