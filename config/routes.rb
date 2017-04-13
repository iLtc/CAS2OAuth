Rails.application.routes.draw do
  get 'login', to: 'login#login'

  get 'logout', to: 'login#logout'

  get 'validate', to: 'login#validate'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
