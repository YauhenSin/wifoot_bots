module ApiGetData
	extend ActiveSupport::Concern
	require 'net/http'
	require 'json'
	API_URL = 'http://demo.wifoot.ht/api/web-services/'

  included do
    before_filter :api_urls
  end

  def api_urls
  	@urls = {
  		categories: API_URL+'getCategory.php',  #GET
  		leagues: API_URL+'getAllLeagues.php',   #GET
  		get_available_bets: API_URL+'getAllAvailableBet.php', #GET
  		bets_by_category: API_URL+'getAvailableBetByCategory.php',
  		get_teams_by_league: API_URL+'getAllTeamByLeague.php',
  		matches: API_URL+'getMatchByApiID.php',
  		get_club_info: API_URL+'getClubInfo.php'
  	}
  end

  def get_data_from_url(url)
  	uri = URI(url)
  	res = Net::HTTP.get_response(uri)
    return JSON.parse(res.body) if res.is_a?(Net::HTTPSuccess)
  end

  def get_data_params(url, params)
  	uri = URI.parse(url)
	http = Net::HTTP.new(uri.host, uri.port)
	response = http.post(uri.path, params.to_query)
	return JSON.parse(response.body)
  end

  def format_leagues(data)
  	result = "Get All Leagues\n"
  	#{"id":"1","name":"Premier League","image":"1414123273logo_barclays.png","status":"1","api_id":"1"}
  	data.each_with_index do |d, i|
  		result << "#{i+1})#{d["name"]} - Status:#{d["status"]} - API_ID:#{d["api_id"]}\n"
  	end
  	return result
  end

  def format_categories(data)
  	result = "Get All Categories\n"
  	# {"event_category_id":"1","event_name":"Win\/Lose\/Draw","event_rule_id":"0","event_name_creole":"Kale\/Pedu\/Match Nil","image":"1_win_lose_draw.png"}
  	data.each_with_index do |d, i|
  		result << "#{i+1})#{d["event_name"]} - event_name_creole:#{d["event_name_creole"]}\n"
  	end
  	return result
  end

  def format_teams(data)
  	#{"id":"1","api_id":"15","name":"Chelsea","image":"1415076852logo_chelsea_large.png","played":"38","win":"12","draw":"14","lose":"12","mgFor":"59","mgAgainst":"53","gDiff":"6","point":"50","leagueId":"1","clubInfo":null,"clubUrl":"http:\/\/www.premierleague.com\/en-gb\/clubs\/profile.overview.html\/chelsea","stadium":"1"}]
  	result = ""
  	data.each_with_index do |d, i|
  		result << "#{i+1})#{d["name"]} - Played:#{d["played"]} - WIN:#{d["win"]} - DRAW:#{d["draw"]} - LOSE:#{d["lose"]} \nClubUrl:#{d["clubUrl"]}"
  	end
  	return result
  end
end