require 'json'
require "open-uri"
class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include Telegram::Bot::UpdatesController::Session
  include ApiGetData
  context_to_action!
  use_session!

  def start(*)
    session[:stage] = 1
    result = get_data_from_url(@urls[:leagues])
    result = format_leagues_with_images(result)
    reply_with :message, text: "Welcome to WiFoot!\nAvailable leagues:\n"
    result.each do |r|
      reply_with :message, text: r[:text]
      # File.open('app/assets/images/leagues/'+r[:image], 'wb') do |fo|
      #   fo.write open("http://demo.wifoot.ht/image/league/"+r[:image]).read 
      # end
      reply_with :sticker, sticker: File.open('app/assets/images/leagues/'+r[:image]), width: 64, height: 64
    end
  end

  def help(*)
    reply_with :message, text: HELP
  end

  def message(message)
    need_reply = true

    case message['text'].downcase
    when /hello|hi|hey|welcome|salutatuion|hey|greeting|yo|aloha|howdy|hiya|good day|good morning|salute/i
      result = 'Hi, How can I help you today?'
    when /leagues|league/i
      session[:stage] = 1
      result = get_data_from_url(@urls[:leagues])
      result = format_leagues_with_images(result)
      reply_with :message, text: "Available leagues:\n"
      result.each do |r|
        reply_with :message, text: r[:text]
        reply_with :sticker, sticker: File.open('app/assets/images/leagues/'+r[:image])
      end
      need_reply = false
    when /categories|category/i
      result = get_data_from_url(@urls[:categories])
      result = format_categories(result)
    when /matches/i
      if /current/.match(message['text'].downcase)
        result = get_data_params(@urls[:matches], {"page_id" => 0, "curr_status" => 2})
      elsif /future|upcoming|up coming/.match(message['text'].downcase)
        result = get_data_params(@urls[:matches], {"page_id" => 0, "curr_status" => 1})
      elsif /finished|finish|ended|past/.match(message['text'].downcase)
        result = get_data_params(@urls[:matches], {"page_id" => 0, "curr_status" => 3})
      else
        result = get_data_params(@urls[:matches], {"page_id" => 0, "curr_status" => 3})
      end
      result = format_matches(result)
      session[:stage] = 2
    when /bets|bet/i
      result = get_data_from_url(@urls[:get_available_bets])[0..10]
    when /stats|stat/i
      club_name = find_club_name(message['text'])
      result = get_data_params(@urls[:get_club_info], {"name" => club_name})
      result = format_team_with_image(result)
      reply_with :message, text: result[:text]
      if result[:image].present?
        # File.open('app/assets/images/club/'+result[:image], 'wb') do |fo|
        #   fo.write open("http://demo.wifoot.ht/image/club/"+result[:image]).read 
        # end
        reply_with :sticker, sticker: File.open('app/assets/images/club/'+result[:image])
      end
        need_reply = false
    when /scores|score/i
      club_name = find_club_name(message['text'])
      result = get_data_params(@urls[:get_matches_by_club], {"name" => club_name, "page_id" => 0, "curr_status" => 3})
      result = format_club_scores(result)
      session[:stage] = 2
    when /players|details/i
      club_name = find_club_name(message['text'])
      club_id = get_data_params(@urls[:get_club_info], {"name" => club_name}).first["api_id"]
      result = get_data_params(@urls[:get_players_by_club], {"id" => club_id})
      result = format_players(result)
      session[:stage] = 3
    when /help|support|assist|aid/i
      result = HELP
    when /\d/i
      if session[:stage] == 1
        id = /\d/.match(message['text'])
        result = get_data_params(@urls[:matches_by_league], {"id" => id, "page_id" => 0, "curr_status" => 3})
        result = format_matches(result)
        session[:stage] = 2
      elsif session[:stage] == 2
        num = /\d/.match(message['text'])[0].to_i
        id = session[:data][num]
        puts "THIS IS REQUESTED ID #{id}"
        result = get_data_params(@urls[:get_match_by_id], {"id" => id})
        result = format_match(result)
        reply_with :message, text: result
        result = get_data_from_url(@urls[:categories])
        result = format_categories(result)
        reply_with :message, text: result
        need_reply = false
        session[:stage] = 4
      elsif session[:stage] == 3
        num = /\d/.match(message['text'])[0].to_i
        id = session[:data][num]
        result = get_data_params(@urls[:get_player_by_id], {"id" => id})
        result = format_player_with_image(result)
        reply_with :message, text: result[:text]
        if result[:image].present?
          File.open('app/assets/images/players/'+result[:image], 'wb') do |fo|
            fo.write open("http://demo.wifoot.ht/image/players/"+result[:image]).read 
          end
          reply_with :sticker, sticker: File.open('app/assets/images/players/'+result[:image])
        end
        need_reply = false
      elsif session[:stage] == 4
        num = /\d/.match(message['text'])[0].to_i
        id = session[:data][num]
        params = {"id" => 0, "match_id" => session[:match_id], "category_id" => id}
        result = get_data_params(@urls[:get_bets_by_category_match], params)
        result = format_bets(result)
      elsif session[:stage] == 5
        
      else
        result = "Please, select category to search"
      end
    else
      result = "Sorry I can't recognize this phrase. Type help to see how I work"
    end

    puts "-----------#{session.as_json}--------------"

    reply_with :message, text: result.to_s if need_reply
  end

  # def leagues(id = nil)
  #   if league_id
  #     result = get_data_params(@urls[:matches_by_league], {"id" => id, "page_id" => 0, "curr_status" => 3})
  #     result = format_matches(result)
  #   else
  #     save_context :leagues
  #     result = get_data_from_url(@urls[:leagues])
  #     result = format_leagues_with_images(result)
  #     reply_with :message, text: "Available leagues:\n"
  #     result.each do |r|
  #       reply_with :message, text: r[:text]
  #       reply_with :sticker, sticker: File.open('app/assets/images/leagues/'+r[:image])
  #     end
  #   end
  # end

  # def inline_query(query, offset)
  #   query = query.first(10) # it's just an example, don't use large queries.
  #   results = 5.times.map do |i|
  #     {
  #       type: :article,
  #       title: "#{query}-#{i}",
  #       id: "#{query}-#{i}",
  #       description: "description #{i}",
  #       input_message_content: {
  #         message_text: "content #{i}",
  #       },
  #     }
  #   end
  #   answer_inline_query results
  # end

  # There are no such requests from telegram :(
  # If you know, how can this be performed, open an issue pls.
  # def chosen_inline_result(result_id, query)
  #   reply_with :message, "Query: #{query}\nYou've chosen: #{result_id}"
  # end

  # def action_missing(action, *_args)
  #   reply_with :message, text: "Can not perform #{action}" if command?
  # end

    # def memo(*args)
  #   if args.any?
  #     session[:memo] = args.join(' ')
  #     reply_with :message, text: 'Remembered!'
  #   else
  #     reply_with :message, text: 'What should I remember?'
  #     save_context :memo
  #   end
  # end

  # def remind_me
  #   to_remind = session.delete(:memo)
  #   reply = to_remind || 'Nothing to remind'
  #   reply_with :message, text: reply
  # end

  # def keyboard(value = nil, *)
  #   if value
  #     reply_with :message, text: "You've selected: #{value}"
  #   else
  #     save_context :keyboard
  #     reply_with :message, text: 'Select something with keyboard:', reply_markup: {
  #       keyboard: [%w(Lorem Ipsum /cancel)],
  #       resize_keyboard: true,
  #       one_time_keyboard: true,
  #       selective: true,
  #     }
  #   end
  # end

  # def inline_keyboard
  #   reply_with :message, text: 'Check my inline keyboard:', reply_markup: {
  #     inline_keyboard: [
  #       [
  #         {text: 'Answer with alert', callback_data: 'alert'},
  #         {text: 'Without alert', callback_data: 'no_alert'},
  #       ],
  #       [{text: 'Open gem repo', url: 'https://github.com/telegram-bot-rb/telegram-bot'}],
  #     ],
  #   }
  # end

  # def callback_query(data)
  #   if data == 'alert'
  #     answer_callback_query 'This is ALERT-T-T!!!', show_alert: true
  #   else
  #     answer_callback_query 'Simple answer'
  #   end
  # end

  # def image(*)
  #   puts 'start download image'
  #   File.open('hihihi.jpg', 'wb') do |fo|
  #     fo.write open("http://bykvu.com/images/thumbnails2/images/2015/11/comedy-hamster_3497562b-fill-600x375.jpg").read 
  #   end
  #   puts 'start reply photo'
  #   reply_with :photo, photo: File.open('app/assets/images/leagues/1414123273logo_barclays.png')
  #   reply_with :sticker, sticker: File.open('app/assets/images/leagues/1414123273logo_barclays.png')
  # end
end