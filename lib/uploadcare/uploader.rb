require 'mime/types'

module Uploadcare
  class Uploader
    def initialize(options = {})
      @options = Uploadcare::default_settings.merge(options)
    end

    def upload_url url

    end

    def upload_file(path)
      resp = response :post, '/base/', {
        UPLOADCARE_PUB_KEY: @options[:public_key],
        file: Faraday::UploadIO.new(path, MIME::Types.of(path))
      }
      resp['file']
    end
  protected
    def response method, path, params = {}
      connection = Faraday.new url: @options[:upload_url_base] do |faraday|
        faraday.request :multipart
        faraday.request :url_encoded
        faraday.adapter Faraday.default_adapter
        faraday.headers['User-Agent'] = Uploadcare::user_agent
      end
      r = connection.send(method, path, params)
      raise ArgumentError.new(r.body) if r.status != 200
      JSON.parse(r.body)
    end
  end
end
