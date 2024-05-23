module RichTextRenderer
  class HyperlinkRenderer < BaseBlockRenderer
    def render(node)
      "<a href=\"#{node['data']['uri']}\" target='_blank'>#{render_content(node)}</a>"
    end
  end
end
