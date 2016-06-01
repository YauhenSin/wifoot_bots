module ApiGetData
	extend ActiveSupport::Concern
	require 'net/http'
	require 'json'
	API_URL = 'http://demo.wifoot.ht/api/web-services/'
  CLUB_NAMES = ["chelsea", "man city", "southampton", "west ham", "liverpool", "man united", "arsenal", "swansea", "tottenham", "stoke", "bournemouth", "aston villa", "everton", "west brom", "leicester", "crystal palace", "sunderland", "newcastle", "watford", "norwich", "bayern munich", "m'gladbach", "mainz", "hoffenheim", "wolfsburg", "leverkusen", "ingolstadt", "ein frankfurt", "schalke 04", "hannover", "fc koln", "augsburg", "hertha", "dortmund", "stuttgart", "hamburg", "darmstadt", "werder bremen", "juventus", "roma", "sampdoria", "milan", "udinese", "lazio", "napoli", "verona", "inter", "genoa", "fiorentina", "torino", "empoli", "atalanta", "carpi", "palermo", "bologna", "chievo", "sassuolo", "frosinone", "marseille", "paris sg", "bordeaux", "lyon", "st etienne", "nantes", "angers", "lille", "toulouse", "monaco", "montpellier", "nice", "rennes", "stade de reims", "lorient", "bastia", "gfco ajaccio", "caen", "guingamp", "troyes", "barcelona", "sevilla", "real madrid", "valencia", "ath madrid", "villarreal", "celta vigo", "malaga", "vallecano", "getafe", "espanol", "eibar", "betis", "granada", "la coruna", "sociedad", "ath bilbao", "las palmas", "levante", "sp gijon", "carpi"]
  HELP = <<-TXT.strip_heredoc
                 Available cmds:
                'categories' - Get All Categories
                'leagues' - Get All leagues
                'stats of clubname' - Get stats of the teams
                'matches (current future past)' - Get All Matches
                'scores of clubname' - Get all matches with the club
                'players of clubname' - Get all players in the club
                'help' - Get Help list
              TXT
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
  		get_club_info: API_URL+'getClubInfoByName.php',
      get_matches_by_club: API_URL+'getMatchesByClub.php',
      get_match_by_id: API_URL+'getMatchByApiID.php',
      get_players_by_club: API_URL+'getPlayersInfoByTeamId.php',
      get_player_by_id: API_URL+'getPlayerInfoById.php',
      get_bets_by_category_match: API_URL+'availableBetsByMatchCategoryAndPageId.php'
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

  def find_club_name(text)
    club_name = ''
    text.split(/\W+/).each do |word|
      club_name = word if CLUB_NAMES.include?(word.downcase)
    end
    return club_name
  end

  def format_leagues_with_images(data)
    result = []
    data_ids = {}
    data.each_with_index do |d, i|
      hash = {}
      hash[:text] = "#{i+1})#{d["name"]} - Status:#{d["status"]} - API_ID:#{d["api_id"]}\n"
      hash[:image] = "#{d["image"]}"
      result << hash
      data_ids[i+1] = d["id"]
    end
    session[:data] = data_ids
    return result
  end

  def format_categories(data)
    data_ids = {}
  	result = "Bet Categories\n"
  	# {"event_category_id":"1","event_name":"Win\/Lose\/Draw","event_rule_id":"0","event_name_creole":"Kale\/Pedu\/Match Nil","image":"1_win_lose_draw.png"}
  	data.each_with_index do |d, i|
  		result << "#{i+1})#{d["event_name"]}\n"
      data_ids[i+1] = d["event_category_id"]
  	end
    session[:data] = data_ids
  	return result
  end

  def format_bets(data)
    puts data
    result = "Bets types\n"
    if data.is_a?(Array)
      data.each_with_index do |d, i|
        #{"id"=>"8472", "home_id"=>"17", "away_id"=>"756", "home_score"=>"0", "away_score"=>"0", "league_id"=>"1", "FTR"=>"D", "status"=>"0", "time"=>"120", "odds"=>"0.66", "match_id"=>"373", "event_category_id"=>"1", "player_id"=>nil, "minute"=>nil, "score_type"=>nil, "event_type"=>nil, "quantity"=>nil, "bet_status"=>"1", "reference"=>nil, "generated_team"=>nil}
        result << "#{i+1})#{d["0"]["home"][0]["name"]} #{d["home_score"]} : #{d["away_score"]} #{d["1"]["away"][0]["name"]}\nOdds: #{d["odds"]}; - Time: #{d['time']}\n"
        # data_ids[i+1] = d["event_category_id"]
      end
    else
      result =  "result is empty"
    end
    return result
  end

  def format_team_with_image(data)
    d = data.first
    {
      text: "#{d["name"]} - Played:#{d["played"]} - WIN:#{d["win"]} - DRAW:#{d["draw"]} - LOSE:#{d["lose"]}\nPoints: #{d["point"]} - \nClubUrl:#{d["clubUrl"]}\n",
      image: d["image"]
    }
  end


  def format_players(data)
    result = ""
    data_ids = {}
    if data.is_a?(Array)
      session[:stage] = 5
      data.each_with_index do |d, i|
        result << "#{i+1})#{d["name"]}\n"
        data_ids[i+1] = d["api_id"]
      end
    else
      result =  "result is empty"
    end
    session[:data] = data_ids
    return result
    #{"id"=>"329", "api_id"=>"1490", "name"=>"Tomas Rosicky ", "height"=>"1.78", "weight"=>"64.4", "nationality"=>"Czech Republic", "position"=>"Midfielder", "clubId"=>"9", "number"=>"7", "dob"=>"1980-10-03", "dos"=>"2006-05-22", "signing"=>nil, "image"=>nil, "0"=>{"age"=>35}}
  end

  def format_player_with_image(data)
    d = data.first
    image = d["image"]
    text = "#{d["name"]}\n#Position:#{d["position"]} - Number:#{d["number"]}\nHeight:#{d["height"]} - Weight:#{d["weight"]} - Age:#{d["0"]["age"]}\nNationality:#{d["nationality"]}"
    {text: text, image: image}
  end

  def format_matches(data)
  	result = ""
    data_ids = {}
  	if data.is_a?(Array)
	  	data.each_with_index do |d, i|
	  		time = Time.at(d["match_time"].to_f/1000).strftime("%m.%d.%Y at %I:%M%p")
	  		result << "#{i+1})Match Time: #{time}\nHome:#{d["0"]["home"][0]["name"]} - Away:#{d["1"]["away"][0]["name"]}\nScores: #{d["home_score"]} : #{d["away_score"]}\n\n"
        data_ids[i+1] = d["match_id"]
	  	end
  	else
  		result =  "result is empty"
  	end
    session[:data] = data_ids
   # puts data_ids
  	return result
  end

  def format_match(data)
    d = data.first
    session[:match_id] = d["match_id"]
    time = Time.at(d["match_time"].to_f/1000).strftime("%m.%d.%Y at %I:%M%p")
    "Match Time: #{time}\nHome:#{d["0"]["home"][0]["name"]} - Away:#{d["1"]["away"][0]["name"]}\nScores: #{d["home_score"]} : #{d["away_score"]}\n"
  end

  def format_club_scores(data)
    result = ""
    data_ids = {}
    if data.is_a?(Array)
      data.each_with_index do |d, i|
        time = Time.at(d["match_time"].to_f/1000).strftime("%m.%d.%Y at %I:%M%p")
        result << "#{i+1}) #{d["0"]["home"][0]["name"]} #{d["home_score"]}:#{d["away_score"]} #{d["1"]["away"][0]["name"]}\n"
        result << "\n"
        data_ids[i+1] = d["match_id"]
      end
    else
      result =  "result is empty"
    end
    session[:data] = data_ids
    return result
  end
  #{"match_time"=>"1448721000", "homescore"=>"2", "awayscore"=>"0", "id"=>"7391", "home_id"=>"71", "away_id"=>"65", "home_score"=>"1", "away_score"=>"1", "league_id"=>"2", "FTR"=>"D", "status"=>"0", "time"=>"120", "odds"=>"0.5", "match_id"=>"503", "event_category_id"=>"1", "player_id"=>nil, "minute"=>nil, "score_type"=>nil, "event_type"=>nil, "quantity"=>nil, "bet_status"=>"0", "reference"=>nil, "generated_team"=>"0", "0"=>{"home"=>[{"name"=>"Bayern Munich", "image"=>"1414467928logo_bayern.png"}]}, "1"=>{"away"=>[{"name"=>"Hertha", "image"=>"1414468960logo_hertha.png"}]}}


    # def format_player(data)
  #   d = data.first
  #   "#{d["name"]}\n#Position:#{d["position"]} - Number:#{d["number"]}\nHeight:#{d["height"]} - Weight:#{d["weight"]} - Age:#{d["0"]["age"]}\nNationality:#{d["nationality"]}"
  # end

    # def format_team(data)
  #   #{"id":"1","api_id":"15","name":"Chelsea","image":"1415076852logo_chelsea_large.png","played":"38","win":"12","draw":"14","lose":"12","mgFor":"59","mgAgainst":"53","gDiff":"6","point":"50","leagueId":"1","clubInfo":null,"clubUrl":"http:\/\/www.premierleague.com\/en-gb\/clubs\/profile.overview.html\/chelsea","stadium":"1"}]
  #   result = ""
  #   if data.is_a?(Array)
   #    data.each_with_index do |d, i|
   #      result << "#{i+1})#{d["name"]} - Played:#{d["played"]} - WIN:#{d["win"]} - DRAW:#{d["draw"]} - LOSE:#{d["lose"]}\nPoints: #{d["point"]} - \nClubUrl:#{d["clubUrl"]}"
  #       end
  #   else
  #     result =  "result is empty"
  #   end
  #   return result
  # end

    # def format_leagues(data)
  #   result = "Available leagues:\n"
  #   #{"id":"1","name":"Premier League","image":"1414123273logo_barclays.png","status":"1","api_id":"1"}
  #   data.each_with_index do |d, i|
  #     result << "#{i+1})#{d["name"]} - Status:#{d["status"]} - API_ID:#{d["api_id"]}\n"
  #   end
  #   return result
  # end


end