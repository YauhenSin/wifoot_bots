#encoding: UTF-8

xml.instruct! :xml, :version => "1.0", :encoding=>"UTF-8"
xml.page :version => "2.0" do
	xml.title 'Available cmds:'
	xml.div "'categories' - Get All Categories"
	xml.div "'leagues' - Get All leagues"
	xml.div "'stats of clubname' - Get stats of the teams"
	xml.div "'matches (current future past)' - Get All Matches"
	xml.div "'scores of clubname' - Get all matches with the club"
	xml.div "'players of clubname' - Get all players in the club"
	xml.div "'help' - Get Help list"

	xml.div do
  	  xml.input name: 'my_input'
    end 
end
