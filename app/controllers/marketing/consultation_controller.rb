class Marketing::ConsultationController < Marketing::ApplicationController
  def index
    @consultation_request = ConsultationRequest.new
  end

  def submit
    @consultation_request = ConsultationRequest.new(consultation_request_params)
    
    # Attempt to save it
    if @consultation_request.save
      # Send internal email
      send_internal_email(@consultation_request)

      # Add contact to GetResponse
      # Based plan_name param, add to appropriate list
      # List : website-general-leads : https://app.getresponse.com/lists/JK0fO
      gr_list_token = 'zuj9Z'
      # List : website-mail-leads : https://app.getresponse.com/lists/JK0mc
      if !consultation_request_params[:plan_name].nil? && consultation_request_params[:plan_name].starts_with?('mail')
        gr_list_token = 'zuj7J'
      # List : website-va-leads : https://app.getresponse.com/lists/JXiHL
      elsif !consultation_request_params[:plan_name].nil? && consultation_request_params[:plan_name].starts_with?('assistant')
        gr_list_token = 'zfLCX'
      end

      response = GetResponseService.new(
        @consultation_request.full_name, 
        @consultation_request.email,
        gr_list_token
      ).add_user

      respond_to do |format|
        format.html { render 'thanks' }
        format.json { render json: { success: true } }
      end
    else
      respond_to do |format|
        format.html {
          flash[:error] = 'An error occurred. Please try again'
          render 'index'
        }
        format.json { render json: { success: false, errors: @consultation_request.errors.to_h } }
      end
    end
  end

  private

  def consultation_request_params
    params.require(:consultation_request).permit(
      :first_name, :last_name, :email, :phone, :business_type, :plan_name, :comment
    )
  end

  def send_internal_email(consultation_request)
    InternalMailer.consultation_email(consultation_request.id).deliver_later
  end
end
