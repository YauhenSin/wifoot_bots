class MessengerBotController < ActionController::Base
  include ApiGetData

  def message(event, sender)
    message = event['message']['text']
    puts "____________________-"
    puts message
    puts "____________________________"
    case message
    when "categories"
      result = get_data_from_url(@urls[:categories])
      puts result
      sender.reply({ text: result })
    when '/start'
      sender.reply({ text: "I am a bot" })
    end
  end

  def delivery(event, sender)
    puts "EVENT delivery"
    puts event
    puts sender
  end

  def postback(event, sender)
    payload = event["postback"]["payload"]
    case payload
    when :something
      #ex) process sender.reply({text: "button click event!"})
    end
  end
end