FactoryGirl.define do
  factory :transaction do
    year Time.now.year
    association :user, :factory => :user
    association :updated_by_user, :factory => :user
    sequence(:amount) { |n| n * 3 }
  end

  factory :tr_comp, :parent => :transaction do
    trantype 'C' # comp
    instrument nil
  end

  factory :tr_refund, :parent => :transaction do
    trantype 'R'
    instrument %w[K S].sample
  end

  factory :tr_sale, :parent => :transaction do
    trantype 'S' # sale
    ins = %w[C S K].sample
    instrument ins
    case ins
    when 'C'
      gwdate { Factory.next(:gwdate) }
      sequence(:gwtranid) { |n| n }
    when 'K'
      check_number 101
    end
  end

  sequence :gwdate do |n|
    month = rand(11) + 1
    day = rand(27) + 1
    Time.utc(Time.now.year, month, day)
  end

end
