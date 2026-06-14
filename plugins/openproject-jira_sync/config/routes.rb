OpenProjectJiraSync::Engine.routes.draw do
  # Прописываем пути для твоих API контроллеров
  namespace :api do
    namespace :v1 do
      # Маршруты для синхронизации с JIRA
      resources :jira_sync, only: [:index, :create]
      
      # Маршруты для запросов на изменение дат
      resources :date_change_requests, only: [:index, :create, :update]
    end
  end
end