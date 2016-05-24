require 'json'
include Facebook::Messenger

class WifootBot

  attr_accessor :sender, :payload

  def initialize(sender, payload)
    @sender = sender
    @payload = payload
  end

  def hello
    bot_deliver('Hi, How can I help you today?')
  end

  def categories
  	result = JSON.parse(get_data_from_url('http://demo.wifoot.ht/api/web-services/getCategory.php'))
  	result = format_categories(result)
    bot_deliver(result)
  end

  def bets
  	result = JSON.parse(get_data_from_url('http://demo.wifoot.ht/api/web-services/getAllAvailableBet.php'))
  	bot_deliver(result)
  end

  def leagues
  	result = JSON.parse(get_data_from_url('http://demo.wifoot.ht/api/web-services/getAllLeagues.php'))
  	result = format_leagues(result)
    bot_deliver(result)
  end

  def matches
  	result = JSON.parse(get_data_from_url('http://demo.wifoot.ht/api/web-services/getMatchByApiID.php'))
  	bot_deliver(result)
  end

  def team
    result = JSON.parse(get_data_params('http://demo.wifoot.ht/api/web-services/getClubInfo.php', {"id" => 15}))
    result = format_teams(result)
    bot_deliver(result)
  end

  def help
    bot_deliver(<<-TXT.strip_heredoc
                    Available cmds:
                    /categories - Get All Categories
                    /bets - Get All Available Bets
                    /leagues - Get All leagues
                TXT
                )
  end

  def unknown
    bot_deliver("Sorry I can't recognize this pharese. Type help to see how I work")
  end

  def bot_deliver(msg)
    Bot.deliver(
      recipient: sender,
      message: {
        text: msg.to_s[0..319]
      }
    )
  end

  def get_data_from_url(url)
  	uri = URI(url)
  	res = Net::HTTP.get_response(uri)
    return res.body if res.is_a?(Net::HTTPSuccess)
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

def get_sender_profile(sender)
  request = HTTParty.get(
    "https://graph.facebook.com/v2.6/#{sender['id']}",
    query: {
      access_token: ENV['FACEBOOK_ACCESS_TOKEN'],
      fields: 'first_name,last_name,gender,profile_pic'
    }
  )

  request.parsed_response
end

def valid?(json)
  JSON.parse(json)
  return true
rescue StandardError
  return false
end

Bot.on :message do |message|
  puts "Received #{message.text} from #{message.sender}"

  bot = WifootBot.new(message.sender, message.text)

  case message.text.downcase
  when /hello/i
    bot.hello
  when /leagues|league/i
    bot.leagues
  when /categories|category/i
    bot.categories
  when /bets|bet/i
    bot.bets
  when /stats|stat/i
    bot.team
  when /help/i
    bot.help
  else
    bot.unknown
  end
end

Bot.on :postback do |postback|
end

Bot.on :delivery do |delivery|
  puts "Delivered message(s) #{delivery.ids}"
end

