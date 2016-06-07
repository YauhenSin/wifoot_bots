require 'facebook_bot'

class TelegramBotController < ApplicationController

	def answer
		bot = WifootBot.new(params[:subscriber], params[:my_input], 0)
		#https://www.codingfish.com/blog/129-how-to-create-rss-feed-rails-4-3-steps
		# render xml: data, :layout => false
		respond_to do |format|
			format.xml { render 'telegram_bot/hi' }
		end
	end

end
