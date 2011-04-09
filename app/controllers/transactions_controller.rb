class TransactionsController < ApplicationController

  # Access Control
  before_filter :allow_only_admin

  # Pagination
  PER_PAGE = 20

  # GET /transactions
  # GET /transactions.xml
  def index
    @transactions = Transaction.order('created_at desc').page(params[:page]).per(PER_PAGE)
  end

  # GET /transactions/1
  # GET /transactions/1.xml
  def show
    @transaction = Transaction.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @transaction }
    end
  end

  # GET /transactions/new
  # GET /transactions/new.xml
  def new
    @transaction = Transaction.new
    @transaction.trantype = 'S' # most trns are sales
    @email_list = get_list_of_user_emails
    @email_picker_value = ''

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @transaction }
    end
  end

  # GET /transactions/1/edit
  def edit
    @transaction = Transaction.find(params[:id])
    @email_list = get_list_of_user_emails
    @email_picker_value = @transaction.user.email
  end

  # POST /transactions
  # POST /transactions.xml
  def create
    @transaction = Transaction.new(params[:transaction])
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
  # PUT /transactions/1.xml
  def update
    @transaction = Transaction.find(params[:id])
    @transaction.updated_by_user = current_user
    @transaction.user_id = User.find_by_email(params[:user_email]).to_param

    @email_list = get_list_of_user_emails
    @email_picker_value = params[:user_email]

    respond_to do |format|
      if @transaction.update_attributes(params[:transaction])
        format.html { redirect_to(@transaction, :notice => 'Transaction was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @transaction.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /transactions/1
  # DELETE /transactions/1.xml
  def destroy
    @transaction = Transaction.find(params[:id])
    @transaction.destroy

    respond_to do |format|
      format.html { redirect_to(transactions_url) }
      format.xml  { head :ok }
    end
  end

protected

  def get_list_of_user_emails
    email_array = User.order('lower(email)').collect {|u| [u.email] }
    email_array.join(',')
  end

end
