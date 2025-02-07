class Api::V1::AccountsController < ApplicationController
  def logged_in
    if current_account
      render json: { logged_in: true, account: current_account.as_json(only: [:id, :email]) }
    else
      render json: { logged_in: false }, status: :unauthorized
    end
  end
end
