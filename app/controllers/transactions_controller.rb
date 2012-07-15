class TransactionsController < ApplicationController
  include YearlyController

  # Callbacks, in order
  load_resource
  add_filter_to_set_resource_year
  authorize_resource
  add_filter_restricting_resources_to_year_in_route

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
    %w[user_id year].each{|atr| params.delete(atr)}

    @transaction.year = @year.year
    @transaction.updated_by_user = current_user
    @transaction.user = User.yr(@year).find_by_email(params[:user_email])

    @email_picker_value = params[:user_email]

    if @transaction.save
      redirect_to(@transaction, :notice => 'Transaction created.')
    else
      render :action => "new"
    end
  end

  def update
    %w[user_id year].each{|atr| params.delete(atr)}

    @transaction.updated_by_user = current_user
    @transaction.user = User.yr(@year).find_by_email(params[:user_email])

    @email_picker_value = params[:user_email]

    if @transaction.update_attributes(params[:transaction])
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

  # Helpers
  def user_email_list
    email_array = User.yr(@year).order('lower(email)').collect {|u| [u.email] }
    email_array.join(',')
  end
  helper_method :user_email_list

end
