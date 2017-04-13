Rails.application.routes.draw do
  get 'login', to: 'login#login'

  get 'callback', to: 'login#callback'

  get 'validate', to: 'login#validate'

  get 'logout', to: 'login#logout'



  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
