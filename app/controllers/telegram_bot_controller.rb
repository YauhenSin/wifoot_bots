require 'wifoot_bot_API'

class TelegramBotController < ApplicationController

	def answer
		message = params[:my_input] ? params[:my_input].downcase : ''
		stage = session[:stage] ? session[:stage] : 1
		data = session[:data] ? session[:data] : {}

		wifoot_api = WifootBotAPI.new(nil, nil, message, stage, data)

		case message
		when ''
			@leagues = wifoot_api.leagues
			session[:stage] = 1
			template = 'telegram_bot/start'
		when /hello|hi|hey|welcome|salutatuion|hey|greeting|yo|aloha|howdy|hiya|good day|good morning|salute/i
			template = 'telegram_bot/hi'
	    when /leagues|league/i
	    	session[:stage] = 1
			template = 'telegram_bot/leagues'
			@leagues = wifoot_api.leagues
	    when /categories|category/i
			bets_categories
	    when /matches/i
	        template = 'telegram_bot/matches'
	      	session[:stage] = 2
	      	@matches = wifoot_api.matches
	    when /bets|bet/i
			bets(message)
	    when /stats|stat/i
			stats(message)
	    when /scores|score/i
			scores(message)
	    when /players|details/i
			players(message)
	    when /help|support|assist|aid/i
			template = 'telegram_bot/help'
	    when /\d/i
			if session[:stage] == 1
				template = 'telegram_bot/matches'
				session[:stage] = 2
				@matches = wifoot_api.matches_by_league
			elsif session[:stage] == 2
				template = 'telegram_bot/match_and_categories'
				session[:stage] = 4
				@match = wifoot_api.match
				@categories = wifoot_api.categoies
			elsif session[:stage] == 3
			player(message)
			elsif session[:stage] == 4
			bets(message)
			elsif session[:stage] == 5
			wifoot_pass
			else
			result = "Please, select category to search"
			reply_with :message, text: result
			end
	    else
			#template = 'telegram_bot/missing'
			template = 'telegram_bot/start'
	    end
	    session[:data] = wifoot_api.data
	    puts "Session: #{session.as_json}"

		respond_to do |format|
			format.xml { render template }
		end		
	end

end
