Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  namespace :api do
    namespace :v1 do
      jsonapi_resources :accounts do
        get 'logged_in', on: :collection
      end
      jsonapi_resources :family_members
      jsonapi_resources :stories

      post 'export_to_pdf/family_member/:id', to: 'export#family_member'
    end
  end
end
