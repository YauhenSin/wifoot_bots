require 'net/http'
class MessengerBotController < ActionController::Base

  def message(event, sender)
    message = event['message']['text']
    case message
    when "categories"
      resp = get_categories
      sender.reply({ text: resp })
    when "categories string"
      resp = get_categories.to_s
      sender.reply({ text: resp })
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

  private

  def get_categories
    uri = URI('http://demo.wifoot.ht/api/web-services/getCategory.php')
    #params = { :limit => 10, :page => 3 }
    #params = {}
    #uri.query = URI.encode_www_form(params)

    res = Net::HTTP.get_response(uri)
    return res.body if res.is_a?(Net::HTTPSuccess)
  end

end