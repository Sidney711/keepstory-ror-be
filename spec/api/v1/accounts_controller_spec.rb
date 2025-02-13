require 'rails_helper'

RSpec.describe Api::V1::AccountsController, type: :controller do
  describe "GET #logged_in" do
    context "when the user is logged in" do
      let(:account) { create(:account) }

      before do
        allow(controller).to receive(:current_account).and_return(account)
      end

      it "returns the login information and account details" do
        get :logged_in

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['logged_in']).to eq(true)
        expect(json['account']['id']).to eq(account.id)
        expect(json['account']['email']).to eq(account.email)
      end
    end

    context "when the user is not logged in" do
      before do
        allow(controller).to receive(:current_account).and_return(nil)
      end

      it "returns the not logged in status with HTTP status 401 (unauthorized)" do
        get :logged_in

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)

        expect(json['logged_in']).to eq(false)
        expect(json).not_to have_key('account')
      end
    end
  end
end