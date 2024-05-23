# Monkey patch for URI.escape
# URI.escape is removed after Ruby 3.0
# but used in Paperclip/lib/paperclip/url_generator.rb
module URI
    def self.escape url
      URI::Parser.new.escape url
    end
  end
  