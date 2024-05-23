class LandingController < ApplicationController
  skip_after_action :intercom_rails_auto_include # Hide Intercom bubble

  def index
  end

  def submit_email
    person = Pipedrive::Person.search(
      params[:email],
      extact_match: true,
      fields: [:name, :email]
    )[0]
    unless person.present?
      person = Pipedrive::Person.create(
        name: params[:email],
        email: params[:email]
      )
    end
    # lead = Pipedrive::Lead.create(
    #   title: "Mailmate US lead",
    #   person_id: person.id
    # )
    deal = Pipedrive::Deal.create(
      title: "Mailmate US lead",
      person_id: person.id,
      pipeline_id: ENV.fetch("PIPEDRIVE_PIPELINE_ID")
    )
    redirect_to "https://calendly.com/morgan-269/mailmate?hide_gdpr_banner=1&primary_color=18bfff",allow_other_host: true
  end
end