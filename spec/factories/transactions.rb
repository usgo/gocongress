FactoryBot.define do

  # The `:base_transaction` represents the attributes
  # common to all other factories.  It does not have enough
  # attributes to be valid, but that's ok because we never use
  # it directly in any tests.
  factory :base_transaction, :class => :transaction do
    year { Time.now.year }
    association :user, factory: :user, strategy: :build
    association :updated_by_user, factory: :user, strategy: :build
    sequence(:amount) { |n| n * 3 }
  end

  # To use the `shared_examples_for_controllers`, we need a valid
  # factory with the same name as the model.  I've chosen to copy
  # `:tr_comp` because it is the simplest.
  factory :transaction, :parent => :base_transaction do
    trantype { 'C' } # comp
    instrument { nil }
  end

  factory :tr_comp, :parent => :base_transaction do
    trantype { 'C' } # comp
    instrument { nil }
  end

  factory :tr_refund, :parent => :base_transaction do
    trantype { 'R' }
    i = %w[K S].sample
    instrument { i }
    check_number { 101 } if (i == 'K')
  end

  factory :tr_sale, :parent => :base_transaction do
    trantype { 'S' } # sale
    ins = %w[C S].sample
    instrument { ins }
    if ins == 'C'
      gwdate { generate(:gwdate) }
      sequence(:gwtranid) { |n| n }
    end
  end

  sequence :gwdate do |n|
    month = rand(11) + 1
    day = rand(27) + 1
    Time.utc(Time.now.year, month, day)
  end

end
