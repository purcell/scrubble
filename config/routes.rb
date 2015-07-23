Rails.application.routes.draw do
  resources :games do
    resource :placements
    resource :tile_swaps
    resource :turn_passes
  end
end
