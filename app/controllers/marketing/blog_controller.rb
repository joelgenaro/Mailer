class Marketing::BlogController < Marketing::ApplicationController
  include ContentfulConcern

  before_action :set_show_newsletter_modal

  def index
    @posts = contentful_entries(t('marketing.pages.blog.blogPost'), { order: '-fields.publishedOn', 'fields.unlisted[ne]': true, limit: per_page, skip: current_offset })

    respond_to do |format|
      format.html
      format.rss { render :layout => false }
    end
  end

  def show
    @post = contentful_find_by!(t('marketing.pages.blog.blogPost'), { 'fields.slug': params[:slug] })
    @popular_posts = contentful_entries(t('marketing.pages.blog.blogPost'), { order: '-fields.publishedOn', limit: 4, 'sys.id[ne]': @post.id })
  end

  def show_category
    @category = contentful_find_by!('blogCategory', 'fields.slug': params[:slug])
    @posts = contentful_entries(t('marketing.pages.blog.blogPost'), 'fields.categories.sys.id': @category.id, 'fields.unlisted[ne]': true, order: '-fields.publishedOn', limit: per_page, skip: current_offset)
  end

  def show_author
    @author = contentful_find_by!('blogPostAuthor', 'fields.slug': params[:slug])
    @posts = contentful_entries(t('marketing.pages.blog.blogPost'), 'fields.author.sys.id': @author.id, 'fields.unlisted[ne]': true, order: '-fields.publishedOn', limit: per_page, skip: current_offset)
  end

  protected

  def set_show_newsletter_modal
    @layout_show_newsletter_modal = true
  end

end
