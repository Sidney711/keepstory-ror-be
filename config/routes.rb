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

      jsonapi_resources :educations
      jsonapi_resources :employments
      jsonapi_resources :marriages
      jsonapi_resources :residence_addresses
      jsonapi_resources :additional_attributes

      jsonapi_resources :family_members do
        member do
          patch :update_profile_picture
          delete :delete_profile_picture
          patch :update_signature
          delete :delete_signature

          patch :upload_images
          get   :show_images

          patch :upload_documents
          get   :show_documents
        end
        delete '/images/:image_id', to: 'family_members#delete_image', as: :delete_image
        delete '/documents/:document_id', to: 'family_members#delete_document', as: :delete_document
      end
    end
  end
end
