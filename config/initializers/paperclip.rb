# A custom interpolation to handle our specific use case; paths that were created before our models were namespaced
Paperclip::interpolates :class_basename do |attachment, style_name|
  return super() if attachment.nil? && style_name.nil?
  attachment.instance.class.name.underscore.split('/').last.pluralize
end

# Production
if Rails.env.production?
  # AWS
  # See https://github.com/thoughtbot/paperclip/wiki/Paperclip-with-Amazon-S3 for policy
  Paperclip::Attachment.default_options[:storage] = :s3
  Paperclip::Attachment.default_options[:s3_credentials] = {
    access_key_id:     ENV.fetch('AWS_S3_ACCESS_KEY_ID'),
    secret_access_key: ENV.fetch('AWS_S3_SECRET_ACCESS_KEY'),
    bucket:            ENV.fetch('AWS_S3_BUCKET_NAME')
  }
  Paperclip::Attachment.default_options[:s3_region] = ENV.fetch('AWS_S3_REGION')
  Paperclip::Attachment.default_options[:url] = ':s3_domain_url'
  Paperclip::Attachment.default_options[:path] = 'storage/:class_basename/:attachment/:id_partition/:style/:filename'
  Paperclip::DataUriAdapter.register
end

# Development
if Rails.env.development?
  Paperclip::Attachment.default_options[:url] = '/storage/:class_basename/:attachment/:id_partition/:style/:filename'
  Paperclip::Attachment.default_options[:path] = ':rails_root/public/storage/:class_basename/:attachment/:id_partition/:style/:filename'

  # Binaries path... assuming we're running in Docker
  Paperclip.options[:command_path] = "/usr/bin/"
end

# Test
if Rails.env.test?
  Paperclip::Attachment.default_options[:path] = ':rails_root/tmp/storage/:class_basename/:attachment/:id_partition/:style/:filename'
end
