#encoding: UTF-8

xml.instruct! :xml, :version => "1.0", :encoding=>"UTF-8"
xml.page :version => "2.0" do
	xml.div "Sorry I can't recognize this phrase. Type help to see how I work"

  xml.div do
  	xml.input name: 'my_input'
  end
end
