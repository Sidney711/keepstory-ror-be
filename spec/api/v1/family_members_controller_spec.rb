require 'rails_helper'

RSpec.describe Api::V1::FamilyMembersController, type: :controller do
  let(:account) { create(:account) }
  let(:family) { create(:family, account: account) }

  before do
    allow(controller).to receive(:authenticate).and_return(true)
    allow(controller).to receive(:current_account).and_return(account)
    allow(Family).to receive(:where).with(account_id: account.id).and_return([family])
  end

  describe "POST #create" do
    let(:valid_attributes) do
      {
        first_name: 'John',
        last_name: 'Doe',
        date_of_birth: '1990-01-01',
        deceased: false
      }
    end

    context "with valid parameters" do
      it "creates a new family member and returns HTTP status :created" do
        expect {
          post :create, params: { data: { attributes: valid_attributes } }
        }.to change(FamilyMember, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['id']).to be_present
        expect(json['first_name']).to eq('John')
        expect(json['last_name']).to eq('Doe')
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) do
        {
          first_name: '',
          last_name: 'Doe',
          date_of_birth: '1990-01-01',
          deceased: false
        }
      end

      it "does not add a family member and returns HTTP status :unprocessable_entity" do
        expect {
          post :create, params: { data: { attributes: invalid_attributes } }
        }.not_to change(FamilyMember, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json).to have_key('first_name')
      end
    end
  end
end
