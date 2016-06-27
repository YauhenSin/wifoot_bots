#encoding: UTF-8

xml.instruct! :xml, :version => "1.0", :encoding=>"UTF-8"
xml.page :version => "2.0" do
  xml.div "Hi, I'm WifootMiniApps bot!"
  # xml.div "\nType 'bet' and choose league for your bet!"
  # xml.div "\n'team' - information about team"
  # xml.div "\n'player' - information about some player"
  xml.div "\nIf you want to see all available commands type 'help'"

  xml.navigation id: 'submit', attributes: 'telegram.inline: true' do
    xml.link 'Bet', pageId: 'answer.xml?my_input=bet'
    xml.link 'Team', pageId: 'answer.xml?my_input=team'
    xml.link 'Player', pageId: 'answer.xml?my_input=player'
  end

  xml.div do
    xml.input name: 'my_input'
  end
end
