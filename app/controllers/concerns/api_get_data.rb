module ApiGetData
	extend ActiveSupport::Concern
	require 'net/http'

  included do
    before_filter :api_urls
  end

  def api_urls
  	@urls = {
  		categories: 'http://demo.wifoot.ht/api/web-services/getCategory.php',
  		available_bets: 'http://demo.wifoot.ht/api/web-services/getAllAvailableBet.php',
  		leagues: 'http://demo.wifoot.ht/api/web-services/getAllLeagues.php',
  		matches: 'http://demo.wifoot.ht/api/web-services/getMatchByApiID.php'
  	}
  end

  def get_data_from_url(url)
  	uri = URI(url)
  	res = Net::HTTP.get_response(uri)
    return res.body if res.is_a?(Net::HTTPSuccess)
  end
end