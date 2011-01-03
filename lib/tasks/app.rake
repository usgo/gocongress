namespace :app do
  desc 'Grant admin privileges to the specified user'
  task :grant_admin, [:email] => :environment do |t,args|
    user = User.find_by_email(args[:email])

    raise "Unknown email #{args[:email]}" unless user

    # Set admin flag and save
    user.is_admin = true
    user.save!

    # We had to succeed to get to this point, since :save!
    # throws an exception on failure.
    puts "Success!"
  end
end
