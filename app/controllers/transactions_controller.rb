class TransactionsController < ApplicationController
  include DollarController
  include YearlyController

  # Callbacks, in order
  add_filter_converting_param_to_cents :amount
  load_resource
  add_filter_to_set_resource_year
  authorize_resource
  add_filter_restricting_resources_to_year_in_route
  before_action :set_attrs_from_params, :only => [:create, :update]

  # Pagination
  PER_PAGE = 20

  # Actions
  def index
    @transactions = @transactions.yr(@year)
    if params[:email].present? then
      search_expression = '%' + params[:email] + '%'
      @transactions = @transactions.joins(:user).where("email like ?", search_expression)
    end
    @transactions = @transactions.order('created_at desc').page(params[:page]).per(PER_PAGE)
  end

  def new
    @transaction.trantype = 'S' # most trns are sales
    @email_picker_value = ''
  end

  def edit
    @email_picker_value = @transaction.user.email
  end

  def create
    @transaction.year = @year.year
    @email_picker_value = params[:user_email]

    if @transaction.save
      redirect_to(@transaction, :notice => 'Transaction created.')
    else
      render :action => "new"
    end
  end

  def update
    @email_picker_value = params[:user_email]

    if @transaction.update_attributes(transaction_params)
      redirect_to(@transaction, :notice => 'Transaction updated.')
    else
      render :action => "edit"
    end
  end

  def destroy
    @transaction.destroy
    redirect_to(transactions_url)
  end

  private

  # `set_attrs_from_params` sets inaccessible transaction attributes
  def set_attrs_from_params
    sanitize_params
    @transaction.updated_by_user = current_user
    @transaction.user = User.yr(@year).where(email: params[:user_email]).first
  end

  # `sanitize_params` deletes a few inaccessible transaction
  # attributes from the params hash
  def sanitize_params
    if params[:transaction].present?
      %w[user_id year].each{ |atr| params[:transaction].delete(atr) }
    end
  end

  def transaction_params
    params.require(:transaction).permit(:instrument, :trantype, :amount,
      :gwtranid, :gwdate, :check_number, :comment)
  end

  # View Helpers

  def user_email_list
    email_array = User.yr(@year).order('lower(email)').collect {|u| [u.email] }
    email_array.join(',')
  end
  helper_method :user_email_list

end
