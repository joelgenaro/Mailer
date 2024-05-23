module Marketing::ConsultationHelper
  def business_type_options_for_select
    options_for_select(business_type_options)
  end

  def business_type_options
    if I18n.locale == :ja
      return [
        ['多忙なビジネスパーソン', 'busy_executive'],
        ['中小企業', 'sme'],
        ['スタートアップ', 'startup'],
        ['NPO法人', 'nonprofit'],
        ['教育機関', 'educational_institution'],
        ['その他', 'other']
      ]
    else
      return [
        ['Busy Executive', 'busy_executive'],
        ['Small/Medium Business', 'sme'],
        ['Startup', 'startup'],
        ['Nonprofit', 'nonprofit'],
        ['Educational Institution', 'educational_institution'],
        ['Other', 'other']
      ]
    end
  end
end
