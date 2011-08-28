Gocongress::Application.routes.draw do

  # http://guides.rubyonrails.org/routing.html

  get "home/access_denied"
  get "home/index"
  get "home/transportation"
  get "home/kaboom"
  get 'contact' => 'user_jobs#index'
  get 'prices_and_extras' => 'plans#prices_and_extras'
  get 'pricing' => 'home#pricing'
  get 'room_and_board' => 'plans#room_and_board'

  match '/popup/:action' => 'popup', :as => 'popup'

  devise_for :users

  # support multiple years by scoping the resources
  scope ":year" do
    resources :contents, :discounts, :events, :jobs
    resources :tournaments
  end

  # restful resources
  resources :plans, :plan_categories, :transactions

  # some resources do not need all seven default actions
  resources :preregistrants, :only => [:index]

  # override resource route for attendee#edit to supoort multiple pages
  match '/attendees/:id/edit/:page' => "attendees#edit"

  resources :attendees do
    collection do
      get 'vip'
    end
    member do
      get 'print_summary', :as => 'print_summary_for'
      get 'print_badge', :as => 'print_badge_for'
    end
  end

  resources :users do
    member do
      get 'edit_email', :as => 'edit_email_for'
      get 'edit_password', :as => 'edit_password_for'
      get 'invoice'
      get 'ledger'
      get 'pay'
      get 'print_cost_summary', :as => 'print_cost_summary_for'
      get 'choose_attendee'

      # todo: attendees should probably be a nested resource of users
      # see http://guides.rubyonrails.org/routing.html#nested-resources
      get 'attendees/new' => 'attendees#new', :as => 'add_attendee_to'
    end
  end

  # reports (not a restful resource, but this is a nice compact syntax)
  resource :reports, :only => [] do
    get :attendees, :atn_badges_all, :atn_badges_ind, :atn_reg_sheets
    get :emails, :events, :index, :invoices, :revenue
    get :outstanding_balances, :overdue_deposits
    get :tournaments, :transactions, :user_invoices
  end

  # these routes should come last
  get ":year" => 'home#index'
  root :to => "home#index"
end
