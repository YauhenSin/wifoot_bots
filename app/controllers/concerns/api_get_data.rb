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
  		matches: API_URL+'getAllMatches.php', #POST
  		matches_by_league: API_URL+'getMatchesByLeague.php', #POST
  		get_available_bets: API_URL+'getAllAvailableBet.php', #GET
  		bets_by_category: API_URL+'getAvailableBetByCategory.php',
  		get_teams_by_league: API_URL+'getAllTeamByLeague.php',
  		get_club_info: API_URL+'getClubInfoByName.php'
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
    puts response.body
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
    puts data
  	#{"id":"1","api_id":"15","name":"Chelsea","image":"1415076852logo_chelsea_large.png","played":"38","win":"12","draw":"14","lose":"12","mgFor":"59","mgAgainst":"53","gDiff":"6","point":"50","leagueId":"1","clubInfo":null,"clubUrl":"http:\/\/www.premierleague.com\/en-gb\/clubs\/profile.overview.html\/chelsea","stadium":"1"}]
  	result = ""
  	if data.is_a?(Array)
	  	data.each_with_index do |d, i|
	  		result << "#{i+1})#{d["name"]} - Played:#{d["played"]} - WIN:#{d["win"]} - DRAW:#{d["draw"]} - LOSE:#{d["lose"]}\nPoints: #{d["point"]} - \nClubUrl:#{d["clubUrl"]}"
	  	end
	else
		result =  "result is empty"
	end
  	return result
  end

  def format_matches(data)
  	result = ""
  	if data.is_a?(Array)
	  	data.each_with_index do |d, i|
	  		time = Time.at(d["match_time"].to_f/1000).strftime("%m.%d.%Y at %I:%M%p")
	  		result << "#{i+1})Match Time: #{time}\nHome:#{d["0"]["home"][0]["name"]} - Away:#{d["1"]["away"][0]["name"]}\nScores: #{d["home_score"]} : #{d["away_score"]}\n"
	  		result << "\n"
	  	end
	else
		result =  "result is empty"
	end
  	return result
  end

  #{"match_time"=>"1448721000", "homescore"=>"2", "awayscore"=>"0", "id"=>"7391", "home_id"=>"71", "away_id"=>"65", "home_score"=>"1", "away_score"=>"1", "league_id"=>"2", "FTR"=>"D", "status"=>"0", "time"=>"120", "odds"=>"0.5", "match_id"=>"503", "event_category_id"=>"1", "player_id"=>nil, "minute"=>nil, "score_type"=>nil, "event_type"=>nil, "quantity"=>nil, "bet_status"=>"0", "reference"=>nil, "generated_team"=>"0", "0"=>{"home"=>[{"name"=>"Bayern Munich", "image"=>"1414467928logo_bayern.png"}]}, "1"=>{"away"=>[{"name"=>"Hertha", "image"=>"1414468960logo_hertha.png"}]}}

end