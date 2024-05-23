# Controller for growth related things on Marketing site
class Marketing::GrowthController < ApplicationController

  # Endpoint partners should redirect users to, with their code (eg /referrer/cic)
  def referrer
    # Ensure valid referrer code
    code = params[:code]&.downcase
    if !code || !Growth::Referrer.find_by(code: code).present?
      redirect_to root_path, notice: "Invalid referrer" and return
    end

    # Drop cookie for 7 days and redirect to mail pricing page
    cookies[:tkm_referrer] = {
      value: code,
      expires: 7.days.from_now
    }
    redirect_to '/pricing/mail'
  end
end
