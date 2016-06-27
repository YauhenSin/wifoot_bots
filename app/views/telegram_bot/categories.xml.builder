#encoding: UTF-8

xml.instruct! :xml, :version => "1.0", :encoding=>"UTF-8"
xml.page :version => "2.0" do

  xml.div "\nBet Categories:"
  # index = 1
  # for category in @categories
  #   xml.div "#{index}) #{category["event_name"]}"
  #   index += 1
  # end


  xml.navigation id: 'submit', attributes: 'telegram.inline: true' do
    @categories.each_with_index {|category, i|
      xml.link category['event_name'], pageId: "answer.xml?my_input=#{@inputs[i+1]}"
    }
  end



  xml.div do
    xml.input name: 'my_input'
  end
end