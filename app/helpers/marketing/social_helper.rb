module Marketing::SocialHelper
  def tweet_url(text, url, url_options = {})
    url_options[:text] = "#{text} #{url}" # via @...
    url_options[:hashtags] = url_options[:hashtags].join(',') if url_options[:hashtags].present?

    "https://twitter.com/intent/tweet?#{CGI.unescape(url_options.to_query)}"
  end

  def tweet_button(text, url, url_options = {})
    html_options = { class: 'twitter-hashtag-button', data: { size: 'large', show: { count: 'false' } } }

    link_to 'Tweet', tweet_url(text, url, url_options), html_options
  end

  def tweet_icon(text, url, url_options = {})
    html_options = { target: '_blank', class: 'social-icon social-icon--twitter' }

    link_to tweet_url(text, url, url_options), html_options do
      content_tag :i, nil, class: 'fab fa-twitter'
    end
  end

  def share_url(url, url_options = {})
    url_options[:u] = url
    url_options[:src] = 'sdkpreparse'

    "https://www.facebook.com/sharer/sharer.php?#{CGI.unescape(url_options.to_query)}"
  end

  def share_button(url, url_options = {})
    html_options = { class: 'fb-share-button', data: { href: url, layout: 'button', size: 'large' } }

    content_tag :div, html_options do
      link_to 'Share', share_url(url, url_options), target: '_blank', class: 'fb-xfbml-parse-ignore'
    end
  end

  def share_icon(url, url_options = {})
    html_options = { target: '_blank', class: 'social-icon social-icon--facebook' }

    link_to share_url(url, url_options), html_options do
      content_tag :i, nil, class: 'fab fa-facebook'
    end
  end
end