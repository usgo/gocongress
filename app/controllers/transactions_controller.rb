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
    @transaction.user_id = User.find_by_email(params[:user_email]).to_param

    @email_list = get_list_of_user_emails
    @email_picker_value = params[:user_email]

    if @transaction.save
      redirect_to(@transaction, :notice => 'Transaction was successfully created.')
    else
      render :action => "new"
    end
  end

  # PUT /transactions/1
  def update
    @transaction.updated_by_user = current_user
    @transaction.user_id = User.find_by_email(params[:user_email]).to_param

    @email_list = get_list_of_user_emails
    @email_picker_value = params[:user_email]

    if @transaction.update_attributes(params[:transaction])
      redirect_to(@transaction, :notice => 'Transaction was successfully updated.')
    else
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
    email_array = User.order('lower(email)').collect {|u| [u.email] }
    email_array.join(',')
  end

end
