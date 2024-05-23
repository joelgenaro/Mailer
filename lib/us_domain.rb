class UsDomain
  def self.matches? request
    if Rails.env.production?
      request.domain == 'mailmate.com'
    else
      request.domain == 'dev-mailmate.com'
    end
  end
end