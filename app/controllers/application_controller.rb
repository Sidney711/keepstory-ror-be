class ApplicationController < ActionController::API
  private

  def authenticate
    rodauth.require_account
  end
end
