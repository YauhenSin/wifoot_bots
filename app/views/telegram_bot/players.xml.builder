#encoding: UTF-8

xml.instruct! :xml, :version => "1.0", :encoding=>"UTF-8"
xml.page :version => "2.0" do
  xml.div "Players: "

  @players.each_with_index {|player, i|
    xml.div "#{i+1}) #{player["name"]}"
  }

  xml.div do
    xml.input name: 'my_input'
  end
end
