class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_locale

  if ENV['BASIC_AUTH_ENABLED']
    http_basic_authenticate_with name: ENV['BASIC_AUTH_USERNAME'], password: ENV['BASIC_AUTH_PASSWORD']
  end

  private

  # Use the appropriaye layout
  # based on if a Devise controller or not
  def layout_by_resource
    if devise_controller?
      "frontend"
    else
      "application"
    end
  end

  def set_locale
    I18n.locale = request.path.starts_with?('/ja') ? :ja : :en
    gon.locale = I18n.locale
  end
end
