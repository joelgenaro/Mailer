class Marketing::PagesController < Marketing::ApplicationController

  # Also used as root/homepage
  def mail 
   
  end

  def ja_landing
  end

  def assistant
  end

  def receptionist
    redirect_to '/' and return
  end

  def faq
  end

  def terms
  end

  def pricing
    # Redirect to /pricing/mail if no specific pricing page is provided
    if params[:page].blank?
      redirect_to marketing_pricing_path('mail') and return
    end
    if params[:page] != 'mail' && params[:page] != 'assistant'
      redirect_to '/' and return
    end
    # Get the correct pricing plans
    case params[:page]
    when 'mail'
      @layout_header_logo = 'mail'
      @layout_footer_overlapping_top = true
      @pricing_plans = Mail::PricingPlansV2.all.reject{|k,v| k.to_s.include?('ja')}
    when 'assistant'
      @layout_header_logo = 'assistant'
      @layout_footer_overlapping_top = true
      @pricing_plans = Assistant::PricingPlansV2.all
    end
    
    # Render the correct view
    render "marketing/pages/pricing/#{params[:page]}"
  end

  def privacy
  end

  def about
  end
end
