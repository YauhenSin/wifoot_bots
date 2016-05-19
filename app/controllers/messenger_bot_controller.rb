class MessengerBotController < ActionController::Base
  def message(event, sender)
    # profile = sender.get_profile
    sender.reply({ text: "Reply: #{event['message']['text']}" })
  end

  def delivery(event, sender)
    # ...stuff...
  end

  def postback(event, sender)
    payload = event["postback"]["payload"]
    case payload
    when :something
      #ex) process sender.reply({text: "button click event!"})
    end
  end
end