Wmcgy::Application.routes.draw do

  resources :users,             only: [:new, :create]
  resources :user_activations,  only: [:new, :create, :update]
  resources :sessions,          only: [:new, :create, :destroy]
  resources :password_resets,   only: [:new, :create, :edit, :update]
  resources :categories,        only: [:index, :create, :destroy, :update]
  resources :transactions
  resources :charts,            only: [:index]
  resources :reports,           only: [:index]
  
  match '/about',   to: 'static_pages#about'
  match '/contact', to: 'static_pages#contact'
  
  match '/signup',                  to: 'users#new'
  match '/signin',                  to: 'sessions#new'
  match '/signout',                 to: 'sessions#destroy'
  match '/signup/complete',         to: 'static_pages#signup_complete'
  
  match '/account/:id/activate',    to: 'user_activations#update',  as: :account_activate
  match '/account/forgot_password', to: 'password_resets#new',      as: :forgot_password
  match '/account/:id/reset_password', to: 'password_resets#edit', as: :reset_password
  match '/account/:id/update_password', to: 'password_resets#update', as: :update_password
  match '/account/account_activation_required', 
     to: 'user_activations#new', as: :account_activation_required
     
  match '/reports/expenses', to: 'reports#expenses'
  match '/reports.expenses', to: 'reports#expenses'
  match '/reports/income', to: 'reports#income'
  match '/reports/income_and_expense', to: 'reports#income_and_expense'
  match '/reports/profit_loss', to: 'reports#profit_loss'
  
  root to: 'transactions#index'
end
