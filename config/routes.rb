Rails.application.routes.draw do
  root 'loads#index'

  resources :loads, only: %i[index show destroy] do
    post :shortlist, on: :member
    post :unshortlist, on: :member
  end
end
