Rails.application.routes.draw do
  resources :games do
    resource :placements
  end
end
