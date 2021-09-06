Rails.application.routes.draw do
  root 'loads#index'

  resources :loads, only: %i[index show destroy] do
    post :shortlist, on: :member
    post :unshortlist, on: :member

    get :shortlist, action: :shortlisted, on: :collection
    post :show_maps, on: :collection
    post :hide_maps, on: :collection
    post :clear_deleted_from_shortlist, on: :collection
  end

  resource :refresh, only: %i[show create]
end
