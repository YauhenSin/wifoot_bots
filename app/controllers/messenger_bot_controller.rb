class MessengerBotController < ActionController::Base
  def message(event, sender)
    sender.reply({ text: "qwe" })
    profile = sender.get_profile
    puts profile.as_json
  end

  def delivery(event, sender)
    puts 'qwe'
  end

  def postback(event, sender)
    puts 'postback'
    payload = event["postback"]["payload"]
    case payload
    when 'hi'
      sender.reply({text: "HI!"})
    end
  end
end