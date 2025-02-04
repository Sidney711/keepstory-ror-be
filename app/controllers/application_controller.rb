class ApplicationController < ActionController::API
  before_action :authenticate

  private

  def authenticate
    rodauth.require_account
  end
end
