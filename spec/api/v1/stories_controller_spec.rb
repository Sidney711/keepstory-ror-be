require 'rails_helper'

RSpec.describe Api::V1::StoriesController, type: :controller do
  let(:account) { create(:account) }
  let(:family)  { create(:family, account: account) }

  before do
    allow(controller).to receive(:authenticate).and_return(true)
    allow(controller).to receive(:current_account).and_return(account)
  end

  describe "POST #create" do
    context "when family exists" do
      before do
        allow(Family).to receive(:find_by).with(account_id: account.id).and_return(family)
      end

      context "with valid parameters" do
        let(:family_member) { create(:family_member, family: family, deceased: false, date_of_death: nil) }
        let(:valid_attributes) do
          {
            title: "Family Reunion",
            content: "We had a wonderful reunion.",
            date_type: "exact",
            story_date: "2020-01-01",
            is_date_approx: false
          }
        end

        let(:relationships) do
          {
            "family_members" => {
              "data" => [
                { "id" => family_member.id }
              ]
            }
          }
        end

        it "creates a new story and returns HTTP status :created" do
          expect {
            post :create, params: { data: { attributes: valid_attributes, relationships: relationships } }
          }.to change(Story, :count).by(1)

          expect(response).to have_http_status(:created)
          json = JSON.parse(response.body)
          expect(json["id"]).to be_present
          expect(json["title"]).to eq("Family Reunion")
        end
      end

      context "with invalid parameters" do
        let(:invalid_attributes) do
          {
            title: "",
            content: "Missing title.",
            date_type: "exact",
            story_date: "2020-01-01",
            is_date_approx: false
          }
        end

        let(:relationships) do
          {
            "family_members" => {
              "data" => []
            }
          }
        end

        it "does not create a new story and returns HTTP status :unprocessable_entity" do
          expect {
            post :create, params: { data: { attributes: invalid_attributes, relationships: relationships } }
          }.not_to change(Story, :count)

          expect(response).to have_http_status(:unprocessable_entity)
          json = JSON.parse(response.body)
          expect(json["errors"]).to include("Story must have at least one family member")
        end
      end
    end

    context "when family does not exist" do
      before do
        allow(Family).to receive(:find_by).with(account_id: account.id).and_return(nil)
      end

      let(:valid_attributes) do
        {
          title: "Missing Family",
          content: "No family associated.",
          date_type: "exact",
          story_date: "2020-01-01",
          is_date_approx: false
        }
      end

      it "returns an error with HTTP status :unprocessable_entity" do
        post :create, params: { data: { attributes: valid_attributes } }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["errors"]).to include("Family was not found.")
      end
    end
  end
end
