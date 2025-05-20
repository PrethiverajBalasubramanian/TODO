Rails.application.routes.draw do
  scope "/todo/api" do
    resources :topics do
      resources :items, :reminders
      post "/items/actions/mark_all_done", to: "items#mark_all_done"
      post "/items/actions/mark_all_undone", to: "items#mark_all_undone"
      post "/reminders/{id}/actions/pause", to: "reminders#pause"
      post "/reminders/{id}/actions/resume", to: "reminders#resume"
    end
    delete "/topics", to: "topics#destroy_all"
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
