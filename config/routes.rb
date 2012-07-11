Gocongress::Application.routes.draw do

  # Put the root route at the top so that it is matched quickly
  root :to => "home#index", :via => :get

  # It's time to get strict about format.  If someone requests a .php,
  # that's a 404!  I'd like to add :format => false to all my routes,
  # but it makes my routes file way too ugly, even if I use
  # with_options().  This constraint has the same effect.
  constraints :format => // do

    get "home/access_denied"

    # kaboom is an intentional error to test runtime exception notification
    get "home/kaboom"

    # these routes support multiple years with a year scope
    scope ":year" do

      # :year must be numeric
      constraints :year => /\d+/ do

        get 'edit' => 'years#edit', :as => :edit_year
        put '' => 'years#update', :as => :update_year

        get 'costs' => 'plan_categories#index'
        get 'pricing' => 'home#pricing'

        devise_for :users, :controllers => { :registrations => "registrations" }

        resources :content_categories, :contents, :discounts,
          :activity_categories, :plan_categories, :tournaments,
          :transactions
        resources :activities, :except => [:index]
        resources :attendee_statistics, :only => :index
        resources :contacts, :except => [:show]
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

        # The reports_controller is deprecated, except for the index
        # action.  Use the rpt namespace below.
        resources :reports, :only => :index do
          collection do
            get :atn_badges_all, :atn_badges_ind, :atn_reg_sheets,
              :emails, :activities, :invoices,
              :tournaments, :user_invoices
          end
        end

        # The "rpt" namespace has one controller for each report.
        # This replaces the deprecated reports_controller.
        namespace :rpt do
          resource :attendeeless_user_report, :only => :show
          resource :outstanding_balance_report, :only => :show

          # These reports support CSV format
          constraints :format => /(csv)?/ do
            resource :attendee_report, :only => :show
            resource :transaction_report, :only => :show
          end
        end

        # defunct?
        root :to => 'home#index', :as => :year, :via => :get

      end # end constraint
    end # end scope
  end # end constraint

end
