xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0", 'xmlns:media': 'http://search.yahoo.com/mrss/' do
  xml.channel do
    xml.title "Blog | MailMate"
    xml.description "Making it easier to work, live and do business in Japan."
    xml.link marketing_blog_url

    @posts.each do |post|
      xml.item do
        xml.title post.title
        xml.description post.description.strip
        xml.pubDate post.published_on.to_s(:rfc822)
        xml.link marketing_blog_post_url(post.slug)
        xml.guid marketing_blog_post_url(post.slug)
        xml.media(:content, :url => contentful_cover_image_url(post), :medium => :image)
        xml.enclosure(:url => contentful_cover_image_url(post), :type => file_mime_type(contentful_cover_image_url(post)))
      end
    end
  end
end