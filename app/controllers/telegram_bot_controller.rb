class TelegramBotController < ApplicationController

	def message
		#https://www.codingfish.com/blog/129-how-to-create-rss-feed-rails-4-3-steps
		# render xml: data, :layout => false
		respond_to do |format|
			format.xml
		end
	end

end
