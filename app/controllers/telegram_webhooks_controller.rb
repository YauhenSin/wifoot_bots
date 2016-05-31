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
      reply_with :photo, photo: File.open('app/assets/images/leagues/'+r[:image])
    end
  end


  def image(*)
    #puts 'start download image'
    # File.open('hihihi.jpg', 'wb') do |fo|
    #   fo.write open("http://bykvu.com/images/thumbnails2/images/2015/11/comedy-hamster_3497562b-fill-600x375.jpg").read 
    # end
    puts 'start reply photo'
    reply_with :photo, photo: open('http://demo.wifoot.ht/image/league/1414123273logo_barclays.png').read
  end

  def help(*)
    reply_with :message, text: <<-TXT.strip_heredoc
                 Available cmds:
                'categories' - Get All Categories
                'leagues' - Get All leagues
                'stats of clubname' - Get stats of the teams
                'matches (current future past)' - Get All Matches
                'scores of clubname' - Get all matches with the club
                'players of clubname' - Get all players in the club
                'help' - Get Help list
              TXT
  end

  def memo(*args)
    if args.any?
      session[:memo] = args.join(' ')
      reply_with :message, text: 'Remembered!'
    else
      reply_with :message, text: 'What should I remember?'
      save_context :memo
    end
  end

  def remind_me
    to_remind = session.delete(:memo)
    reply = to_remind || 'Nothing to remind'
    reply_with :message, text: reply
  end

  def keyboard(value = nil, *)
    if value
      reply_with :message, text: "You've selected: #{value}"
    else
      save_context :keyboard
      reply_with :message, text: 'Select something with keyboard:', reply_markup: {
        keyboard: [%w(Lorem Ipsum /cancel)],
        resize_keyboard: true,
        one_time_keyboard: true,
        selective: true,
      }
    end
  end

  def inline_keyboard
    reply_with :message, text: 'Check my inline keyboard:', reply_markup: {
      inline_keyboard: [
        [
          {text: 'Answer with alert', callback_data: 'alert'},
          {text: 'Without alert', callback_data: 'no_alert'},
        ],
        [{text: 'Open gem repo', url: 'https://github.com/telegram-bot-rb/telegram-bot'}],
      ],
    }
  end

  def callback_query(data)
    if data == 'alert'
      answer_callback_query 'This is ALERT-T-T!!!', show_alert: true
    else
      answer_callback_query 'Simple answer'
    end
  end

  def message(message)
    case message['text'].downcase
    when /hello|hi|hey|welcome|salutatuion|hey|greeting|yo|aloha|howdy|hiya|good day|good morning|salute/i
      result = 'Hi, How can I help you today?'
    when /leagues|league/i
      session[:stage] = 1
      result = get_data_from_url(@urls[:leagues])
      result = format_leagues(result)
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
      result = format_teams(result)
    when /scores|score/i
      club_name = find_club_name(message['text'])
      result = get_data_params(@urls[:get_matches_by_club], {"name" => club_name, "page_id" => 0, "curr_status" => 3})
      result = format_club_scores(result)
      session[:stage] = 2
    when /players|team details/i
      club_name = find_club_name(message['text'])
      club_id = get_data_params(@urls[:get_club_info], {"name" => club_name}).first["api_id"]
      result = get_data_params(@urls[:get_players_by_club], {"id" => club_id})
      result = format_players(result)
      session[:stage] = 3
    when /help|support|assist|aid/i
      result = <<-TXT.strip_heredoc
                 Available cmds:
                'categories' - Get All Categories
                'leagues' - Get All leagues
                'stats of clubname' - Get stats of the teams
                'matches (current future past)' - Get All Matches
                'scores of clubname' - Get all matches with the club
                'players of clubname' - Get all players in the club
                'help' - Get Help list
              TXT
    when /\d/i
      if session[:stage] == 1
        id = /\d/.match(message['text'])
        result = get_data_params(@urls[:matches_by_league], {"id" => id, "page_id" => 0, "curr_status" => 3})
        result = format_matches(result)
        session[:stage] = 2
      elsif session[:stage] == 2
        num = /\d/.match(message['text'])[0].to_i
        id = session[:data][num]
        puts id
        result = get_data_params(@urls[:get_match_by_id], {"id" => id})
        result = format_match(result)
        session[:stage] = 0
      elsif session[:stage] == 3
        num = /\d/.match(message['text'])[0].to_i
        id = session[:data][num]
        result = get_data_params(@urls[:get_player_by_id], {"id" => id})
        result = format_player(result)
        #session[:stage] = 0
      else
        result = "Please, select category to search"
      end
    else
      result = "Sorry I can't recognize this phrase. Type help to see how I work"
    end

    reply_with :message, text: result.to_s
  end

  def inline_query(query, offset)
    query = query.first(10) # it's just an example, don't use large queries.
    results = 5.times.map do |i|
      {
        type: :article,
        title: "#{query}-#{i}",
        id: "#{query}-#{i}",
        description: "description #{i}",
        input_message_content: {
          message_text: "content #{i}",
        },
      }
    end
    answer_inline_query results
  end

  # There are no such requests from telegram :(
  # If you know, how can this be performed, open an issue pls.
  def chosen_inline_result(result_id, query)
    reply_with :message, "Query: #{query}\nYou've chosen: #{result_id}"
  end

  def action_missing(action, *_args)
    reply_with :message, text: "Can not perform #{action}" if command?
  end
end