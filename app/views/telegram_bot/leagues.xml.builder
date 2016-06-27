#encoding: UTF-8

xml.instruct! :xml, :version => "1.0", :encoding=>"UTF-8"
xml.page :version => "2.0" do
  xml.div "Available leagues: "

  # @leagues.each_with_index {|league, i|
  #   xml.div "#{i+1}) #{league["name"]}"
    # xml.attachment type: "photo", src: "http://demo.wifoot.ht/image/league/"+league["image"]
  # }

  xml.navigation id: 'submit', attributes: 'telegram.inline: true' do
    @leagues.each_with_index {|league, i|
      xml.link league['name'], pageId: "answer.xml?my_input=#{@inputs[i+1]}"
    }
  end

  xml.div do
    xml.input name: 'my_input'
  end

  # xml.navigation id: "submit" do
  #   xml.link "help", pageId: "answer.xml"
  # end

  # xml.input navigation: "submit", name: "keyboard_input"
end
