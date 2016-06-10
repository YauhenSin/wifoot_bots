#encoding: UTF-8

xml.instruct! :xml, :version => "1.0", :encoding=>"UTF-8"
xml.page :version => "2.0" do
	xml.div "Available leagues: "
	
	for league in @leagues
	  	xml.div "#{league["id"]}) #{league["name"]}"
		xml.attachment type: "photo", src: "http://demo.wifoot.ht/image/league/"+league["image"]
	end

	xml.input name: 'my_input'

	# xml.navigation id: "submit" do
	# 	xml.link "help", pageId: "answer.xml"
	# end

	# xml.input navigation: "submit", name: "keyboard_input"
end
