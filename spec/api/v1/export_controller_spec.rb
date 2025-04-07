require 'rails_helper'

RSpec.describe Api::V1::ExportController, type: :controller do
  include ActiveJob::TestHelper

  let(:account)       { create(:account) }
  let(:family)        { create(:family, account: account) }
  let(:family_member) { create(:family_member, family: family, deceased: false, date_of_death: nil) }

  before do
    allow(controller).to receive(:authenticate).and_return(true)
    allow(controller).to receive(:current_account).and_return(account)
    # Simulate lookup of the current family by current_account
    allow(Family).to receive(:where).with(account_id: account.id).and_return([family])
  end

  describe "GET #family_member" do
    context "when language is 'cs'" do
      it "enqueues ExportFamilyMemberCsJob and returns HTTP status :accepted" do
        expect {
          get :family_member, params: { id: family_member.id, language: 'cs' }
        }.to have_enqueued_job(ExportFamilyMemberCsJob).with(family_member.id)
        expect(response).to have_http_status(:accepted)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Export PDF byl zařazen do fronty.")
      end
    end

    context "when language is not 'cs'" do
      it "enqueues ExportFamilyMemberEnJob and returns HTTP status :accepted" do
        expect {
          get :family_member, params: { id: family_member.id, language: 'en' }
        }.to have_enqueued_job(ExportFamilyMemberEnJob).with(family_member.id)
        expect(response).to have_http_status(:accepted)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Export PDF byl zařazen do fronty.")
      end
    end
  end

  describe "GET #family" do
    context "when language is 'cs'" do
      it "enqueues ExportFamilyCsJob and returns HTTP status :accepted" do
        expect {
          get :family, params: { language: 'cs' }
        }.to have_enqueued_job(ExportFamilyCsJob).with(family.id)
        expect(response).to have_http_status(:accepted)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Export PDF byl zařazen do fronty.")
      end
    end

    context "when language is not 'cs'" do
      it "enqueues ExportFamilyEnJob and returns HTTP status :accepted" do
        expect {
          get :family, params: { language: 'en' }
        }.to have_enqueued_job(ExportFamilyEnJob).with(family.id)
        expect(response).to have_http_status(:accepted)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Export PDF byl zařazen do fronty.")
      end
    end
  end

  describe "GET #family_tree" do
    it "enqueues ExportFamilyTreeJob with the correct parameters and returns HTTP status :accepted" do
      expect {
        get :family_tree, params: { id: family_member.id, language: 'en' }
      }.to have_enqueued_job(ExportFamilyTreeJob).with(family_member.id, 'en')
      expect(response).to have_http_status(:accepted)
      json = JSON.parse(response.body)
      expect(json["message"]).to eq("Export PDF byl zařazen do fronty.")
    end
  end
end
