Gocongress::Application.routes.draw do
  get "home/access_denied"
  get "home/kaboom"

  # Deprecated: do not use popups as they will just get blocked
  match '/popup/:action' => 'popup', :as => 'popup'

  devise_for :users

  # these routes support multiple years with a year scope
  scope ":year" do
    get 'contact' => 'user_jobs#index'
    get 'costs' => 'plan_categories#index'
    get 'pricing' => 'home#pricing'

    resources :content_categories, :contents, :discounts, :jobs
    resources :plan_categories, :tournaments, :transactions
    resources :events, :except => [:index]
    resources :event_categories, :only => [:show]
    resources :plans, :except => [:index]

    resources :attendees, :except => :edit do
      collection do
        get 'vip'
      end
      member do
        get 'print_summary', :as => 'print_summary_for'
        get 'print_badge', :as => 'print_badge_for'
      end
    end

    # Replace the normal attendee#edit with a route that supports multiple pages
    get '/attendees/:id/edit/:page' => "attendees#edit", :as => :atnd_edit_page

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
      get :emails, :events, :index, :invoices
      get :outstanding_balances, :overdue_deposits
      get :tournaments, :transactions, :user_invoices
    end

  end

  # deprecated routes: redirect with 301 status code
  # these routes will be deleted eventually
  get 'contact' => redirect('/2012/contact')

  # these routes should come last
  get ":year" => 'home#index', :as => :year
  root :to => "home#index"
end
