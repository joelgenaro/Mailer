class ActionView::Helpers::FormBuilder
  # https://stackoverflow.com/questions/5646855/how-to-show-error-messages-next-to-field
  def error_message_for(field_name)
    if self.object.errors[field_name].present?
      model_name              = self.object.class.name.downcase
      id_of_element           = "error_#{model_name}_#{field_name}"
      target_elem_id          = "#{model_name}_#{field_name}"
      error_declaration_class = 'has-signup-error'

      "<div id=\"#{id_of_element}\" for=\"#{target_elem_id}\" class=\"form_errors\">"\
      "#{self.object.errors[field_name].join(', ')}"\
      "</div>".html_safe
    end
  rescue
    nil
  end

  # Returns the form group class for a form field
  def form_group(field_name, html_options = {})
    classes = html_options[:class] || 'form-group'
    classes = classes.split(' ') || []
    classes << 'has-error' if self.object.errors[field_name].present?
    @template.content_tag :div, class: classes.join(' ') do
      yield
    end
  end
end
