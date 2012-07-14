require "spec_helper"

describe ContactsController do
  it_behaves_like "an admin controller", :contact
end
