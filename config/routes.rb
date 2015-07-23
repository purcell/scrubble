Rails.application.routes.draw do
  resources :games do
    resource :placements
    resource :tileswaps
  end
end
