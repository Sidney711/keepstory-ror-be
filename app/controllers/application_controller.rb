class ApplicationController < ActionController::API
  include JSONAPI::ActsAsResourceController

  def authenticate
    rodauth.require_account
  end

  def current_account
    rodauth.rails_account
  end
end
