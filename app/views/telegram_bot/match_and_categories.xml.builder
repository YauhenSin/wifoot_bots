#encoding: UTF-8

xml.instruct! :xml, :version => "1.0", :encoding=>"UTF-8"
xml.page :version => "2.0" do

	time = Time.at(@match["match_time"].to_f/1000).strftime("%m.%d.%Y at %I:%M%p")
	xml.div "#{index}) Home: #{@match["0"]["home"][0]["name"]} - Away: #{@match["1"]["away"][0]["name"]}"
	xml.div "Scores: #{@match["home_score"]} : #{@match["away_score"]}"
	xml.div "Match Time: #{time}"


	xml.div "\nBet Categories:"
	index = 1
	for category in @categories
		xml.div "#{index}) #{category["event_name"]}"
		index += 1
	end

	xml.div do
		xml.input name: 'my_input'
	end
end