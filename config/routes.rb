Gocongress::Application.routes.draw do

  get "preregistrant/index"
  get "home/access_denied"
  get "home/index"
  get "home/transportation"
  get "home/kaboom"

  match 'preregistrants' => 'preregistrant#index', :as => 'preregistrants'
  match 'contact' => 'user_jobs#index'
  match '/popup/:action' => 'popup', :as => 'popup'
  match 'prices_and_extras' => 'plans#prices_and_extras'
  match 'pricing' => 'home#pricing'
  match 'room_and_board' => 'plans#room_and_board'
  match 'vip' => 'attendees#vip'

  devise_for :users

  # override resource route for attendee#edit to supoort multiple pages
  match '/attendees/:id/edit/:page' => "attendees#edit"

  # resource routes (maps HTTP verbs to controller actions automatically):
  resources :attendees, :contents, :discounts, :events, :jobs
  resources :plans, :plan_categories, :tournaments, :transactions

  resources :users do
    member do
      get 'invoice'
      get 'ledger'
      get 'pay'
    end
  end

  # reports
  match 'reports' => 'reports#index'
  get "reports/emails"
  get "reports/overdue_deposits"
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "home#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
