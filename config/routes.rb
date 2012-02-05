Gocongress::Application.routes.draw do

  # It's time to get strict about format.  If someone requests a .php,
  # that's a 404!  I'd like to add :format => false to all my routes,
  # but it makes my routes file way too ugly, even if I use
  # with_options().  This constraint has the same effect.
  constraints :format => // do

    get "home/access_denied"

    # kaboom is an intentional error to test airbrake
    get "home/kaboom"

    # these routes support multiple years with a year scope
    scope ":year" do

      # :year must be numeric
      constraints :year => /\d+/ do

        get 'contact' => 'user_jobs#index'
        get 'costs' => 'plan_categories#index'
        get 'pricing' => 'home#pricing'

        devise_for :users, :controllers => { :registrations => "registrations" }

        resources :content_categories, :contents, :discounts, :activity_categories
        resources :jobs, :plan_categories, :tournaments, :transactions
        resources :activities, :except => [:index]
        resources :plans, :except => [:index]

        resources :attendees, :except => :edit do
          collection do
            get 'vip'
          end
          member do
            get 'print_summary', :as => 'print_summary_for'
            get 'print_badge', :as => 'print_badge_for'

            # Replace #edit with a route that supports multiple pages
            get 'edit/:page', :action => :edit, :as => :edit

            # Because there are so many plans, we want to show one category at
            # a time. Because we are batch-editing attendee_plan records, it
            # does not make sense to use nested resources here.
            get 'edit/plans/:plan_category_id', :action => :edit_plans, :as => :edit_plans_for
            put 'edit/plans/:plan_category_id', :action => :update_plans, :as => :update_plans_for
          end
        end

        resources :users, :except => [:new, :create] do
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

          get :atn_badges_all, :atn_badges_ind, :atn_reg_sheets,
            :emails, :activities, :index, :invoices, :outstanding_balances,
            :tournaments, :user_invoices

          # these two reports are the only routes in the entire app
          # that allow the :format dynamic segment.
          constraints :format => /(csv)?/ do
            get :attendees, :transactions
          end
        end

        root :to => 'home#index', :as => :year, :via => :get

      end # end constraint
    end # end scope
  end # end constraint

  root :to => "home#index", :via => :get
end
