class ContactsController < ApplicationController
  include YearlyController

  # Callbacks, in order
  load_resource
  add_filter_to_set_resource_year
  authorize_resource
  add_filter_restricting_resources_to_year_in_route

  # Actions
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
    if @contact.update_attributes!(contact_params)
      redirect_to contacts_path, :notice => 'Contact updated'
    else
      render :action => "edit"
    end
  end

  def destroy
    @contact.destroy
    redirect_to contacts_path, :notice => 'Contact deleted'
  end

  private

  def contact_params
    params.require(:contact).permit(:email, :family_name, :given_name,
      :list_order, :phone, :title)
  end
end
