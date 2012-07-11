class ContactsController < ApplicationController
  include YearlyController
  load_and_authorize_resource

  def index
    @contacts = @contacts.yr(@year).order(:list_order)
  end

  def create
    @contact.year = @year.year
    if @contact.save
      redirect_to contacts_path, :notice => 'Contact added'
    else
      render :action => "new"
    end
  end

  def update
    if @contact.update_attributes(params[:contact])
      redirect_to contacts_path, :notice => 'Contact updated'
    else
      render :action => "edit"
    end
  end

  def destroy
    @contact.destroy
    redirect_to contacts_path, :notice => 'Contact deleted'
  end

end
