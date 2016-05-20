module ApiGetData
	extend ActiveSupport::Concern
	require 'net/http'

  included do
    before_filter :api_urls
  end

  def api_urls
  	@urls = {
  		categories: 'http://demo.wifoot.ht/api/web-services/getCategory.php'
  	}
  end

  def get_data_from_url(url)
  	uri = URI(url)
  	res = Net::HTTP.get_response(uri)
    return res.body if res.is_a?(Net::HTTPSuccess)
  end
end