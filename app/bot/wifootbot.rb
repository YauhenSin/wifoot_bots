require 'json'
include Facebook::Messenger

class WifootBot

  attr_accessor :sender, :payload

  def initialize(sender, payload)
    @sender = sender
    @payload = payload
  end

  def hello
  	Bot.deliver(
      recipient: sender,
      message: {
        text: 'Hello, human!'
      }
    )
  end

  def categories
  	result = JSON.parse(get_data_from_url('http://demo.wifoot.ht/api/web-services/getCategory.php'))
  	Bot.deliver(
      recipient: sender,
      message: {
        text: result.to_s[0..319]
      }
    )
  end

  def bets
  	result = JSON.parse(get_data_from_url('http://demo.wifoot.ht/api/web-services/getAllAvailableBet.php'))
  	Bot.deliver(
      recipient: sender,
      message: {
        text: result[0].to_s[0..319]
      }
    )
  end

  def leagues
  	result = JSON.parse(get_data_from_url('http://demo.wifoot.ht/api/web-services/getAllLeagues.php'))
  	Bot.deliver(
      recipient: sender,
      message: {
        text: result.to_s[0..319]
      }
    )
  end

  def matches
  	result = JSON.parse(get_data_from_url('http://demo.wifoot.ht/api/web-services/getMatchByApiID.php'))
  	Bot.deliver(
      recipient: sender,
      message: {
        text: result.to_s[0..319]
      }
    )
  end

  def help
    Bot.deliver(
      recipient: sender,
      message: {
        text: <<-TXT.strip_heredoc
			      Available cmds:
			      /categories - Get All Categories
			      /bets - Get All Available Bets
			      /leagues - Get All leagues
      			  /matches - Get All matches
			  TXT
      }
    )
  end

  def get_data_from_url(url)
  	uri = URI(url)
  	res = Net::HTTP.get_response(uri)
    return res.body if res.is_a?(Net::HTTPSuccess)
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

  case message.text
  when /hello/i
    bot.hello
  when '/categories'
  	bot.categories
  when '/bets'
  	bot.bets
  #when '/matches'
  #	bot.matches
  when '/leagues'
  	bot.leagues
  when '/help'
  	bot.help
  else
  	bot.help
  end	
end

Bot.on :postback do |postback|
end

Bot.on :delivery do |delivery|
  puts "Delivered message(s) #{delivery.ids}"
end

#https://github.com/hyperoslo/facebook-messenger-demo/blob/master/app/bots/product_bot.rb