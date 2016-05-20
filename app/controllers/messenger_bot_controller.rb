class MessengerBotController < ActionController::Base
  include ApiGetData

  def message(event, sender)
    message = event['message']['text']
    case message
    when "/categories"
      result = ''
      data = JSON.parse(get_data_from_url(@urls[:categories]))
      data.each do |d|
        result += d['event_name']
      end
      sender.reply({ text: "#{result}" })
    when '/start'
      sender.reply({ text: "I am a bot" })
    end
  end

  def delivery(event, sender)
  end

  def postback(event, sender)
    payload = event["postback"]["payload"]
    case payload
    when :something
      #ex) process sender.reply({text: "button click event!"})
    end
  end
end