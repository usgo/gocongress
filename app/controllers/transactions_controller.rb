class TransactionsController < ApplicationController

  load_and_authorize_resource

  # Pagination
  PER_PAGE = 20

  # GET /transactions
  def index
    @transactions = @transactions.yr(@year)
    if params[:email].present? then
      search_expression = '%' + params[:email] + '%'
      @transactions = @transactions.joins(:user).where("email like ?", search_expression)
    end
    @transactions = @transactions.order('created_at desc').page(params[:page]).per(PER_PAGE)
  end

  # GET /transactions/1
  def show
  end

  # GET /transactions/new
  def new
    @transaction.trantype = 'S' # most trns are sales
    @email_list = get_list_of_user_emails
    @email_picker_value = ''
  end

  # GET /transactions/1/edit
  def edit
    @email_list = get_list_of_user_emails
    @email_picker_value = @transaction.user.email
  end

  # POST /transactions
  def create
    @transaction.year = @year
    @transaction.updated_by_user = current_user
    @transaction.user = User.yr(@year).find_by_email(params[:user_email])

    @email_list = get_list_of_user_emails
    @email_picker_value = params[:user_email]

    if @transaction.save
      redirect_to(@transaction, :notice => 'Transaction created.')
    else
      render :action => "new"
    end
  end

  # PUT /transactions/1
  def update
    extra_errors = []
    @transaction.updated_by_user = current_user
    @email_list = get_list_of_user_emails
    @email_picker_value = params[:user_email]

    if params[:user_email].present?
      u = User.yr(@year).find_by_email(params[:user_email])
      if u.nil? then extra_errors << "Could not find a user with that email" end
      @transaction.user_id = u.id
    end

    if extra_errors.empty? && @transaction.update_attributes(params[:transaction])
      redirect_to(@transaction, :notice => 'Transaction updated.')
    else
      extra_errors.each { |e| @transaction.errors[:base] << e }
      render :action => "edit"
    end
  end

  # DELETE /transactions/1
  def destroy
    @transaction.destroy
    redirect_to(transactions_url)
  end

protected

  def get_list_of_user_emails
    email_array = User.yr(@year).order('lower(email)').collect {|u| [u.email] }
    email_array.join(',')
  end

end
