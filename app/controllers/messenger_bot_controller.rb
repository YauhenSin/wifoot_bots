class MessengerBotController < ActionController::Base
  def message(event, sender)
    puts "_______"
    puts event
    puts sender.profile
    puts sender
    puts event['message']['text']

    # profile = sender.get_profile
    sender.reply({ text: "qwe" })
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