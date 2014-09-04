require "spec_helper"

describe ContactsController, :type => :controller do
  it_behaves_like "an admin controller", :contact do
    let(:updateable_attribute) { :family_name }
  end
end
