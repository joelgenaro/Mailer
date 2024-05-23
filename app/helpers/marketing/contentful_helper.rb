module Marketing::ContentfulHelper
  def contentful_rich_text(content)
    content = RichTextRenderer::Renderer.new.render(content)

    # If you want to test shortcodes, can just add them in here and 
    # alter below line to:
    shortcode_testing = <<~EOM
      [newsletter_subscription_button type=paper_work_mistakes]Show Paperwork Mistakes[/newsletter_subscription_button]
      [newsletter_subscription_button type=small_business_guide]Show Small Business Guide[/newsletter_subscription_button]
      [newsletter_subscription_button type=company_incorporation_fundamentals]Show Company Incorporation in Japan[/newsletter_subscription_button]
      [newsletter_subscription_button type=how_to_open_corporate_bank_account]How To Open Corporate Bank Account[/newsletter_subscription_button]
      [embed_audio]https://media.vimejs.com/audio.mp3[/embed_audio]
      [newsletter_subscription_button type=guide_to_b2b_sales]Guide to B2B Sales in Japan[/newsletter_subscription_button]
    EOM
    # content = contentful_process_shortcodes(shortcode_testing + content)
    content = contentful_process_shortcodes(content)
    content.html_safe
  end

  def contentful_categories(categories)
    links = categories.map { |category| link_to(category.title, marketing_blog_category_path(category.slug)) }
    links.join(', ').html_safe
  end

  def contentful_service_listing_category(categories)
    texts = categories.map { |category| category.title }
    texts.join(', ').html_safe
  end

  def contentful_needs_pagination?(entries)
    entries.total.to_i > entries.limit.to_i
  end

  def contentful_on_first_page?(entries)
    entries.skip.to_i == 0
  end

  def contentful_on_last_page?(entries)
    (entries.skip.to_i + entries.limit.to_i) >= entries.total.to_i
  end

  def contentful_last_page(entries)
    entries.total.to_i / entries.limit.to_i
  end

  def contentful_current_page(entries)
    entries.skip.to_i == 0 ? 1 : ((entries.skip.to_i / entries.limit.to_i) + 1)
  end

  def contentful_next_page(entries)
    return nil if contentful_on_last_page?(entries)
    next_page = contentful_current_page(entries) + 1
    next_page
  end

  def contentful_next_page_path(entries)
    contentful_pagination_path(contentful_next_page(entries))
  end

  def contentful_prev_page(entries)
    return nil if contentful_on_first_page?(entries)
    last_page = contentful_current_page(entries) - 1
    last_page
  end

  def contentful_prev_page_path(entries)
    contentful_pagination_path(contentful_prev_page(entries))
  end

  def contentful_pagination_path(page)
    "#{request.path}?page=#{page}"
  end

  def contentful_image_url(asset)
    "https:#{asset.image_url}"
  end

  def contentful_images_url(assets)
    assets = @service_listing.business_pictures.map do |image| contentful_image_url(image) end
  end

  def contentful_avatar_image_url(entry)
    contentful_image_url(entry.avatar)
  end

  def contentful_cover_image_url(entry)
    return '' unless entry.cover_image.present?
    contentful_image_url(entry.cover_image)
  end

  def contentful_process_shortcodes(content)
    shortcode = Shortcode.new
    shortcode.setup do |config|
      config.block_tags = contentful_block_tags
      config.helpers = [
        Marketing::ContentfulHelper, # Make this helper available in shortcode templates
        React::Rails::ViewHelper # Be able to generate react components in the templates
      ]
      config.use_attribute_quotes = false # Avoid Contentful Rich Text rendering issues
    end
    shortcode.process(content)
  end

  def contentful_block_tags
    [
      :link, 
      :embed_instagram, 
      :embed_youtube, 
      :cta_button, 
      :newsletter_subscription_button,
      # Embeds an audio clip and shows a player:
      # app/javascript/components/blog_audio_player.tsx
      # Use like:
      #   [embed_audio]https://media.vimejs.com/audio.mp3[/embed_audio]
      :embed_audio
    ]
  end
end
