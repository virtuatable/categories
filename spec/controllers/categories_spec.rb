RSpec.describe Controllers::Categories do

  before do
    DatabaseCleaner.clean
  end

  let!(:group) { create(:group) }
  let!(:category) { create(:category) }
  let!(:account) { create(:account) }
  let!(:right) { create(:right, groups: [group], category: category) }
  let!(:application) { create(:application, creator: account) }
  let!(:gateway) { create(:gateway) }

  def app
    Controllers::Categories.new
  end

  describe 'GET /' do
    describe 'in the nominal case' do
      let!(:other_category) { create(:other_category, slug: 'other_category') }
      let!(:other_right) { create(:right, slug: 'another_random_right', groups: [], category: other_category) }

      before do
        get '/', {app_key: 'test_key', token: 'test_token'}
      end

      describe 'Nominal case' do
        let!(:body) { JSON.parse(last_response.body) }

        it 'gives the correct status code when obtaining a right' do
          expect(last_response.status).to be 200
        end
        it 'Returns the right counts for the rights list' do
          expect(body['count']).to be 2
        end
        it 'Returns a hash having categories slugs as keys, and content of categories as values' do
          expect(body['items']).to eq([
            {
              'id' => category.id.to_s,
              'slug' => 'test_category',
              'count' => 1,
              'rights' => [{
                'id' => right.id.to_s,
                'slug' => 'test_right',
                'groups' => 1
              }]
            },
            {
              'id' => other_category.id.to_s,
              'slug' => 'other_category',
              'count' => 1,
              'rights' => [{
                'id' => other_right.id.to_s,
                'slug' => 'another_random_right',
                'groups' => 0
              }]
            }
          ])
        end
      end

      it_should_behave_like 'a route', 'get', '/'
    end
  end

  describe 'POST /' do
    describe 'Nominal case' do
      before do
        post '/', {app_key: 'test_key', token: 'test_token', slug: 'test_other_category'}
      end
      it 'gives the correct status code when successfully creating a right' do
        expect(last_response.status).to be 201
      end
      it 'returns the correct body when the right is successfully created' do
        expect(JSON.parse(last_response.body)).to eq({'message' => 'created'})
      end
    end

    it_should_behave_like 'a route', 'post', '/'


    describe 'bad request errors' do
      describe 'slug not given error' do
        before do
          post '/', {app_key: 'test_key', token: 'test_token'}
        end
        it 'Raises a bad request (400) error when the parameters don\'t contain the slug' do
          expect(last_response.status).to be 400
        end
        it 'returns the correct response if the parameters do not contain a slug' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'missing.slug'})
        end
      end
    end
  end

  describe 'DELETE /:id' do
    describe 'the nominal case' do
      before do
        delete "/#{category.id.to_s}", {app_key: 'test_key', token: 'test_token'}
      end
      it 'Returns a OK (200) status code when deleting a category' do
        expect(last_response.status).to be 200
      end
      it 'Returns the correct body when deleting a category' do
        expect(JSON.parse(last_response.body)).to eq({'message' => 'deleted'})
      end
      it 'Has deleted the category in the database' do
        expect(Arkaan::Permissions::Category.all.count).to be 0
      end
      it 'Has deleted the right in the database' do
        expect(Arkaan::Permissions::Right.all.count).to be 0
      end
    end

    it_should_behave_like 'a route', 'delete', '/category_id'

    describe 'not_found errors' do
      describe 'category not found' do
        before do
          delete "/anything", {token: 'test_token', app_key: 'test_key'}
        end
        it 'Raises a not found (404) error when the category doesn\'t exist' do
          expect(last_response.status).to be 404
        end
        it 'returns the correct body when the category doesn\'t exist' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'category_not_found'})
        end
      end
    end
  end
end