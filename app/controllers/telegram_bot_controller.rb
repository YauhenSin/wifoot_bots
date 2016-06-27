require 'wifoot_bot_API'

class TelegramBotController < ApplicationController

  def answer
    message = params[:my_input] ? params[:my_input].downcase : ''

    case message
      when /bet/i
        session['stage'] = {'type' => 'bet', 'step' => 'leagues'}
      when /team/i
        session['stage'] = {'type' => 'team_info', 'step' => 'leagues'}
      when /player/i
        session['stage'] = {'type' => 'player_info', 'step' => 'leagues'}
      when /hello|hi|hey|welcome|salutatuion|hey|greeting|yo|aloha|howdy|hiya|good day|good morning|salute|start/i
        session['stage'] = {'type' => 'newcomer', 'step' => 'default'}
    end

    stage = session['stage'] ? session['stage'] : {'type' => 'newcomer', 'step' => 'default'}
    data = session[:data] ? session[:data] : {}

    wifoot_api = WifootBotAPI.new(nil, nil, message, stage, data)

    puts stage

    case stage['type']
    when 'newcomer'
      template = 'telegram_bot/hi'
    when 'team_info'
      if stage['step'] == 'leagues'
        session['stage']['step'] = 'teams'
        @leagues = wifoot_api.leagues
        @inputs = wifoot_api.get_inputs
        template = 'telegram_bot/leagues'
      elsif stage['step'] == 'teams'
        session['stage']['step'] = 'team'
        @teams = wifoot_api.teams
        template = 'telegram_bot/teams'
      elsif stage['step'] == 'team'
        session['stage']['step'] = 'show'
        @teams = wifoot_api.team
        template = 'telegram_bot/team'
      end
    when 'player_info'
      if stage['step'] == 'leagues'
        session['stage']['step'] = 'teams'
        @leagues = wifoot_api.leagues
        @inputs = wifoot_api.get_inputs
        template = 'telegram_bot/leagues'
      elsif stage['step'] == 'teams'
        session['stage']['step'] = 'players'
        @teams = wifoot_api.teams
        template = 'telegram_bot/teams'
      elsif stage['step'] == 'players'
        session['stage']['step'] = 'player'
        @teams = wifoot_api.players
        template = 'telegram_bot/players'
      elsif stage['step'] == 'player'
        session['stage']['step'] = 'show'
        @teams = wifoot_api.player
        template = 'telegram_bot/player'
      end
    when 'bet'
      if stage['step'] == 'leagues'
        session['stage']['step'] = 'matches'
        @leagues = wifoot_api.leagues
        @inputs = wifoot_api.get_inputs
        template = 'telegram_bot/leagues'
      elsif stage['step'] == 'matches'
        session['stage']['step'] = 'categories'
        @matches = wifoot_api.matches_by_league
        @inputs = wifoot_api.get_inputs
        template = 'telegram_bot/matches'
      elsif stage['step'] == 'categories'
        session['stage']['step'] = 'bets'
        wifoot_api.match
        @categories = wifoot_api.categories
        @inputs = wifoot_api.get_inputs
        template = 'telegram_bot/categories'
      elsif stage['step'] == 'bets'
        @bets = wifoot_api.bets
        case wifoot_api.get_category
        when 1
          template = 'telegram_bot/bets/win_lose_draw'
        when 4
          template = 'telegram_bot/bets/over_under'
        else
          template = 'telegram_bot/bets/over_under'
        end
      end
    else
      session['stage'] = {'type' => 'newcomer', 'step' => 'default'}
      template = 'telegram_bot/hi'
    end

    # case message
    # when /hello|hi|hey|welcome|salutatuion|hey|greeting|yo|aloha|howdy|hiya|good day|good morning|salute/i
    #   template = 'telegram_bot/hi'
    # when /team/i
    #   session[:stage] = {type: 'team_info', step: 'leagues'}
    #   @leagues = wifoot_api.leagues
    #   template = 'telegram_bot/leagues'
    # when /leagues|league/i
    #   session[:stage] = 1
    #   @leagues = wifoot_api.leagues
    #   template = 'telegram_bot/leagues'
    # when /categories|category/i
    #   bets_categories
    # when /matches/i
    #   session[:stage] = 2
    #   @matches = wifoot_api.matches
    #   template = 'telegram_bot/matches'
    # when /bets|bet/i
    #   bets(message)
    # when /stats|stat/i
    #   stats(message)
    # when /scores|score/i
    #   scores(message)
    # when /players|details/i
    #   players(message)
    # when /help|support|assist|aid/i
    #   template = 'telegram_bot/help'
    # when /\d/i
    #   if session[:stage] == 1
    #     session[:stage] = 2
    #     @matches = wifoot_api.matches_by_league
    #     template = 'telegram_bot/matches'
    #   elsif session[:stage] == 2
    #     session[:stage] = 4
    #     wifoot_api.match
    #     @categories = wifoot_api.categories
    #     template = 'telegram_bot/categories'
    #   elsif session[:stage] == 3
    #     player(message)
    #   elsif session[:stage] == 4
    #     @bets = wifoot_api.bets
    #     case wifoot_api.get_category
    #     when 1
    #       template = 'telegram_bot/bets/win_lose_draw'
    #     when 4
    #       template = 'telegram_bot/bets/over_under'
    #     else
    #       template = 'telegram_bot/bets/over_under'
    #     end
    #   elsif session[:stage] == 5
    #     wifoot_pass
    #   else
    #     result = "Please, select category to search"
    #     reply_with :message, text: result
    #   end
    # else
    # #template = 'telegram_bot/missing'
    # template = 'telegram_bot/hi'
    # end

    session[:data] = wifoot_api.data
    puts "Session: #{session.as_json}"

    respond_to do |format|
      format.xml { render template }
    end
  end

end
