Rails.application.routes.draw do
  root "projects#index"

  resources :projects, path: "proyectos", path_names: { new: "nuevo", edit: "editar" } do
    scope module: :projects do
      resource :student_lead, path: "estudiante-lider", path_names: { new: "nuevo", edit: "editar" }, only: %i[new create edit update]
      resources :sponsorships, path: "patrocinios", only: %i[create destroy]
    end
  end
  resources :sponsors, path: "patrocinadores", path_names: { new: "nuevo", edit: "editar" }
  resources :tutors, path: "tutores", path_names: { new: "nuevo", edit: "editar" }

  resource :session, only: %i[new create destroy]
  resources :passwords, param: :token, only: %i[new create edit update]

  namespace :api do
    namespace :v1, defaults: { format: :json } do
      resources :projects, only: %i[index show]
      resources :sponsors, only: :index
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
