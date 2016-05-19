class MessengerBotController < ActionController::Base
  def message(event, sender)
    payload = event['message']['text']
    case payload
    when "hi"
      sender.reply({ text: "HI" })
    when :hi
      sender.reply({ text: ": HI" })
    when '/start'
      sender.reply({ text: "I am a bot" })
    end
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