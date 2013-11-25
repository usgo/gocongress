namespace :app do
  desc 'Grant admin privileges to the specified user'
  task :grant_admin, [:email] => :environment do |t,args|
    user = User.where(email: args[:email]).first

    raise "Unknown email #{args[:email]}" unless user

    # Set admin flag and save
    user.is_admin = true
    user.save!

    # We had to succeed to get to this point, since :save!
    # throws an exception on failure.
    puts "Success!"
  end
end

namespace :test do
  desc 'Measures test coverage'
  task :coverage do
    rm_f "coverage"
    rm_f "coverage.data"
    rcov = "rcov --rails --aggregate coverage.data --text-summary -Itest"
    system("#{rcov} --no-html test/unit/*_test.rb")
    system("#{rcov} --no-html test/functional/*_test.rb")
  end
end
