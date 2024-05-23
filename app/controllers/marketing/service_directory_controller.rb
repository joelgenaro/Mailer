class Marketing::ServiceDirectoryController < Marketing::ApplicationController
  include ContentfulConcern

  before_action :set_service_categories, :set_category_slug, only: [:index, :show_category_listings, :show_service_listing]
  before_action :set_service_listings, only: [:index]

  def index; end

  def show_category_listings
    @category = contentful_find_by!('serviceCategory', 'fields.slug': params[:category_slug])
    @category_listings = contentful_entries('businessProfile', 'fields.category.sys.id': @category.id)
  end

  def show_service_listing
    @service_listing = contentful_find_by!('businessProfile', { 'fields.slug': params[:slug] })
  end

  private

  def set_service_categories
    @service_categories = contentful_entries('serviceCategory')
  end

  def set_service_listings
    @service_listings = contentful_entries('businessProfile')
  end

  def set_category_slug
    @category_slug = params[:category_slug]
  end

end
