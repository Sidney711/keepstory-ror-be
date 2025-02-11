class ApplicationController < ActionController::API
  include JSONAPI::ActsAsResourceController

  def context
    { current_account: current_account }
  end

  def authenticate
    rodauth.require_account
  end

  def current_account
    rodauth.rails_account
  end
end
