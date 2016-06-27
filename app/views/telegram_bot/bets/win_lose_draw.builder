#encoding: UTF-8

xml.instruct! :xml, :version => "1.0", :encoding=>"UTF-8"
xml.page :version => "2.0" do

  xml.div "\nWin/Lose/Draw:"
  index = 1
  for bet in @bets
    ftr = bet["FTR"] == 'H' ? bet['0']['home'][0]['name'] : bet['1']['away'][0]['name']

    xml.div "#{index}) Odds: #{bet["odds"]};  FTR: #{ftr}"
    index += 1
  end

  xml.div do
    xml.input name: 'my_input'
  end
end