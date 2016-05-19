class MessengerBotController < ActionController::Base
  def message(event, sender)
    sender.reply({ text: "qwe" })
    profile = sender.get_profile
    puts profile.as_json
  end

  def delivery(event, sender)
    sender.reply({ text: "Reply: #{event['message']['text']}" })
  end

  def postback(event, sender)
    puts 'postback'
    payload = event["postback"]["payload"]
    case payload
    when :something
      sender.reply({text: "button click event!"})
    end
  end
end