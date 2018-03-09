FactoryGirl.define do
  factory :empty_category, class: Arkaan::Permissions::Category do
    factory :category do
      _id 'category_id'
      slug 'test_category'

      factory :other_category do
        _id 'other_category_id'
      end
    end
  end
end