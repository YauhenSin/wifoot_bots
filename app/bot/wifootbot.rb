require 'json'
include Facebook::Messenger
require 'facebook_bot'


# def get_sender_profile(sender)
#   request = HTTParty.get(
#     "https://graph.facebook.com/v2.6/#{sender['id']}",
#     query: {
#       access_token: ENV['FACEBOOK_ACCESS_TOKEN'],
#       fields: 'first_name,last_name,gender,profile_pic'
#     }
#   )

#   request.parsed_response
# end

Bot.on :message do |message|
  puts "Received #{message.text} from #{message.sender}"

  bot = WifootBot.new(message.sender, message.text)

  case message.text.downcase
  when /hello|hi|hey|welcome|salutatuion|hey|greeting|yo|aloha|howdy|hiya|good day|good morning|salute/i
    bot.hello
  when /leagues|league/i
    bot.leagues
  when /categories|category/i
    bot.categories
  when /matches/i
    bot.matches
  when /stats|stat/i
    bot.stats
  when /scores|score/i
    bot.scores
  when /players|team details/i
    bot.players
  when /\d/i
    bot.number_selection
  when /help|support|assist|aid/i
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

