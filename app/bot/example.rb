require 'json'
include Facebook::Messenger

Bot.on :message do |message|
  Bot.deliver(
    recipient: message.sender,
    message: {
      text: 'Hello, human!'
    }
  )
end


#https://github.com/hyperoslo/facebook-messenger-demo/blob/master/app/bots/product_bot.rb