#encoding: UTF-8

xml.instruct! :xml, :version => "1.0", :encoding=>"UTF-8"
xml.page :version => "2.0" do

  xml.div "\nOver/Under:"
  index = 1
  for bet in @bets
    if bet["over_under"] == "1"
      xml.div "#{index}) Under #{bet["user_quantity"]}"
    else
      xml.div "#{index}) Over #{bet["user_quantity"]}"
    end
    index += 1
  end

  xml.div do
    xml.input name: 'my_input'
  end
end