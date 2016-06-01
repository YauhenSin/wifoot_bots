require 'json'

CLUB_NAMES = ["chelsea", "man city", "southampton", "west ham", "liverpool", "man united", "arsenal", "swansea", "tottenham", "stoke", "bournemouth", "aston villa", "everton", "west brom", "leicester", "crystal palace", "sunderland", "newcastle", "watford", "norwich", "bayern munich", "m'gladbach", "mainz", "hoffenheim", "wolfsburg", "leverkusen", "ingolstadt", "ein frankfurt", "schalke 04", "hannover", "fc koln", "augsburg", "hertha", "dortmund", "stuttgart", "hamburg", "darmstadt", "werder bremen", "juventus", "roma", "sampdoria", "milan", "udinese", "lazio", "napoli", "verona", "inter", "genoa", "fiorentina", "torino", "empoli", "atalanta", "carpi", "palermo", "bologna", "chievo", "sassuolo", "frosinone", "marseille", "paris sg", "bordeaux", "lyon", "st etienne", "nantes", "angers", "lille", "toulouse", "monaco", "montpellier", "nice", "rennes", "stade de reims", "lorient", "bastia", "gfco ajaccio", "caen", "guingamp", "troyes", "barcelona", "sevilla", "real madrid", "valencia", "ath madrid", "villarreal", "celta vigo", "malaga", "vallecano", "getafe", "espanol", "eibar", "betis", "granada", "la coruna", "sociedad", "ath bilbao", "las palmas", "levante", "sp gijon", "carpi"]
API_URL = 'http://demo.wifoot.ht/api/web-services/'
URLS = {
      categories: API_URL+'getCategory.php',
      leagues: API_URL+'getAllLeagues.php',
      matches: API_URL+'getAllMatches.php',
      matches_by_league: API_URL+'getMatchesByLeague.php', 
      get_available_bets: API_URL+'getAllAvailableBet.php',
      bets_by_category: API_URL+'getAvailableBetByCategory.php',
      get_teams_by_league: API_URL+'getAllTeamByLeague.php',
      get_club_info: API_URL+'getClubInfoByName.php',
      get_matches_by_club: API_URL+'getMatchesByClub.php',
      get_match_by_id: API_URL+'getMatchByApiID.php',
      get_players_by_club: API_URL+'getPlayersInfoByTeamId.php',
      get_player_by_id: API_URL+'getPlayerInfoById.php'
    }


class WifootBot
  attr_accessor :sender, :payload, :stage, :data

  def initialize(sender, payload, stage = 0, data = {})
    @sender = sender
    @payload = payload
    @stage = stage
    @data = data
  end

  def hello
    bot_deliver('Hi, How can I help you today?')
  end

  def categories
  	result = get_data_from_url(URLS[:categories])
  	result = format_categories(result)
    bot_deliver(result)
  end

  def bets
  	result = get_data_from_url('')
  	bot_deliver(result)
  end

  def leagues
  	result = get_data_from_url(URLS[:leagues])
  	result = format_leagues(result)
    bot_deliver(result)
  end

  def matches
    if /current/.match(@payload.downcase)
      result = get_data_params(URLS[:matches], {"page_id" => 0, "curr_status" => 2})
    elsif /future|upcoming|up coming/.match(@payload.downcase)
      result = get_data_params(URLS[:matches], {"page_id" => 0, "curr_status" => 1})
    elsif /finished|finish|ended|past/.match(@payload.downcase)
      result = get_data_params(URLS[:matches], {"page_id" => 0, "curr_status" => 3})
    else
      result = get_data_params(URLS[:matches], {"page_id" => 0, "curr_status" => 3})
    end
  	result, data = format_matches(result)
  	bot_deliver(result)
    data
  end

  def stats
    club_name = find_club_name(@payload)
    result = get_data_params(URLS[:get_club_info], {"name" => club_name})
    result = format_teams(result)
    bot_deliver(result)
  end

  def scores
    club_name = find_club_name(@payload)
    result = get_data_params(URLS[:get_matches_by_club], {"name" => club_name, "page_id" => 0, "curr_status" => 3})
    result, data = format_club_scores(result)
    bot_deliver(result)
    data
  end

  def players
    club_name = find_club_name(@payload)
    club_id = get_data_params(URLS[:get_club_info], {"name" => club_name}).first["api_id"]
    result = get_data_params(URLS[:get_players_by_club], {"id" => club_id})
    result, data = format_players(result)
    bot_deliver(result)
    data
  end

  def number_selection
    if @stage == 1
      id = /\d/.match(@payload)
      result = get_data_params(URLS[:matches_by_league], {"id" => id, "page_id" => 0, "curr_status" => 3})
      result = format_matches(result)
    elsif @stage == 2
      num = /\d/.match(@payload)[0].to_i
      id = @data[num]
      result = get_data_params(URLS[:get_match_by_id], {"id" => id})
      result = format_match(result)
    elsif @stage == 3
      num = /\d/.match(@payload)[0].to_i
      id = @data[num]
      result = get_data_params(URLS[:get_player_by_id], {"id" => id})
      result = format_player(result)
    else
      result = "Please, select category to search"
    end

    bot_deliver(result)
  end

  def help
    bot_deliver(<<-TXT.strip_heredoc
                 Available cmds:
                'categories' - Get All Categories
                'leagues' - Get All leagues
                'stats of clubname' - Get stats of the teams
                'matches (current future past)' - Get All Matches
                'scores of clubname' - Get all matches with the club
                'players of clubname' - Get all players in the club
                'help' - Get Help list
              TXT
                )
  end

  def unknown
    bot_deliver("Sorry I can't recognize this phrese. Type help to see how I work")
  end

  def bot_deliver(msg)
    cutting_msgs(msg).each do |m|
        Bot.deliver(
          recipient: sender,
          message: {
            text: m.to_s[0..319]
          }
        )
    end
  end

  def cutting_msgs(msg)
    result = []
    from = 0
    to = from + 319

    (msg.size/320 + 1).times do |n|
      result << msg[from..to]
      from += 319
      to += 319
    end
    return result
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

  def format_leagues(data)
    result = "Get All Leagues\n"
    #{"id":"1","name":"Premier League","image":"1414123273logo_barclays.png","status":"1","api_id":"1"}
    data.each_with_index do |d, i|
      result << "#{i+1})#{d["name"]}\n"
    end
    return result
  end

  def format_categories(data)
    result = "Get All Categories\n"
    # {"event_category_id":"1","event_name":"Win\/Lose\/Draw","event_rule_id":"0","event_name_creole":"Kale\/Pedu\/Match Nil","image":"1_win_lose_draw.png"}
    data.each_with_index do |d, i|
      result << "#{i+1})#{d["event_name"]}\n"
    end
    return result
  end

  def format_teams(data)
    #{"id":"1","api_id":"15","name":"Chelsea","image":"1415076852logo_chelsea_large.png","played":"38","win":"12","draw":"14","lose":"12","mgFor":"59","mgAgainst":"53","gDiff":"6","point":"50","leagueId":"1","clubInfo":null,"clubUrl":"http:\/\/www.premierleague.com\/en-gb\/clubs\/profile.overview.html\/chelsea","stadium":"1"}]
    result = ""
    if data.is_a?(Array)
      data.each_with_index do |d, i|
        result << "#{i+1})#{d["name"]}\nPlayed: #{d["played"]}; WIN: #{d["win"]}; DRAW: #{d["draw"]}; LOSE: #{d["lose"]}\nPoints: #{d["point"]}\nClub Url: #{d["clubUrl"]}"
        end
    else
      result =  "result is empty"
    end
    return result
  end

  def format_players(data)
    result = ""
    data_ids = {}
    if data.is_a?(Array)
      data.each_with_index do |d, i|
        result << "#{i+1})#{d["name"]}\n"
        data_ids[i+1] = d["api_id"]
      end
    else
      result =  "result is empty"
    end
    return result, data_ids
  end

  def format_player(data)
    puts data
    d = data.first
    "#{d["name"]}\n#Position:#{d["position"]} - Number:#{d["number"]}\nHeight:#{d["height"]} - Weight:#{d["weight"]} - Age:#{d["0"]["age"]}\nNationality:#{d["nationality"]}"
  end

  def format_matches(data)
    puts data
    result = ""
    data_ids = {}
    if data.is_a?(Array)
      data.each_with_index do |d, i|
        time = Time.at(d["match_time"].to_f/1000).strftime("%m.%d.%Y at %I:%M%p")
        result << "#{i+1})Match Time: #{time}\nHome: #{d["0"]["home"][0]["name"]} - Away: #{d["1"]["away"][0]["name"]}\nScores: #{d["home_score"]} : #{d["away_score"]}\n"
        result << "\n"
        data_ids[i+1] = d["match_id"]
      end
    else
      result =  "result is empty"
    end
    @data = data_ids
    return result, @data
  end

  def format_match(data)
    d = data.first
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
    @data = data_ids
    return result, data
  end
end