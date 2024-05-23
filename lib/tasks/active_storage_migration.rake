namespace :active_storage_migration do
  namespace :s3 do
    task copy_mail_items: :environment do
      Mail::MailItem.where.not(file_file_name: nil).find_each do |mail_item|
        filename = CGI.unescape(mail_item.file_file_name)
        id = mail_item.id
        file_url = ("https://#{ENV.fetch('AWS_S3_BUCKET_NAME')}.s3.amazonaws.com/storage/mail_items/files/000/%03d/%03d/original/#{filename}" % [(id/1000).to_i, (id % 1000)])
        begin
          mail_item.file.attach(io: URI.open(file_url),
                                    filename: filename,
                                    content_type: mail_item.file_content_type)
        rescue Exception => e
          puts "Cannot move file #{file_url}"
        end
      end
    end
    task copy_task_uploads: :environment do
      Assistant::TaskUpload.where.not(file_file_name: nil).find_each do |task_upload|
        filename = CGI.unescape(task_upload.file_file_name)
        id = task_upload.id
        file_url = ("https://#{ENV.fetch('AWS_S3_BUCKET_NAME')}.s3.amazonaws.com/storage/task_uploads/files/000/%03d/%03d/original/#{filename}" % [(id/1000).to_i, (id % 1000)])
        begin 
            task_upload.file.attach(io: URI.open(file_url),
                                    filename: filename,
                                    content_type: task_upload.file_content_type)
        rescue Exception => e
            puts "Cannot move file #{file_url}"
        end
      end
    end

    task copy_documents: :environment do
      Document.where.not(file_file_name: nil).find_each do |document|
        filename = CGI.unescape(document.file_file_name)
        id = document.id
        file_url = ("https://#{ENV.fetch('AWS_S3_BUCKET_NAME')}.s3.amazonaws.com/storage/documents/files/000/%03d/%03d/original/#{filename}" % [(id/1000).to_i, (id % 1000)])
        begin 
            document.file.attach(io: URI.open(file_url),
                                        filename: filename,
                                        content_type: document.file_content_type)
        rescue Exception => e
            puts "Cannot move file #{file_url}"

        end
      end
    end

    task copy_payment_attachments: :environment do
      Payment::Attachment.where.not(file_file_name: nil).find_each do |attachment|
        filename = CGI.unescape(attachment.file_file_name)
        id = attachment.id
        file_url = ("https://#{ENV.fetch('AWS_S3_BUCKET_NAME')}.s3.amazonaws.com/storage/attachments/files/000/%03d/%03d/original/#{filename}" % [(id/1000).to_i, (id % 1000)])
        begin 
            attachment.file.attach(io: URI.open(file_url),
                                    filename: filename,
                                    content_type: attachment.file_content_type)
            puts "From paperclip url #{file_url}"
            puts "To AS url #{url_for(attachment.file)}"
        rescue Exception => e
            puts "Cannot move file #{file_url}"
        end
      end
    end
  end
end