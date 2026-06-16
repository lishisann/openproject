OpenProjectJiraSync::Engine.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :jira_sync, only: [:index, :create]
      
      resources :date_change_requests, only: [:index, :create, :update]
    end
  end
end