#encoding: UTF-8

xml.instruct! :xml, :version => "1.0", :encoding=>"UTF-8"
xml.page :version => "2.0" do
	xml.div "Hi, How can I help you today?"

	# xml.navigation id: "submit" do
	# 	xml.link "1", pageId: 'answer.xml', accesskey: 1
	# end

	# xml.div do
	# 	xml.input name: 'keyboard_input', navigationId: "submit"
	# end

	xml.div do
  	  xml.input name: 'my_input'
    end
end
