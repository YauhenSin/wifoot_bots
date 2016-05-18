require 'net/http'

uri = URI('http://api.wifoot.ht/web-services/getCategory.html')
params = { :limit => 10, :page => 3 }
#uri.query = URI.encode_www_form(params)

res = Net::HTTP.get_response(uri)
puts res
puts res.body if res.is_a?(Net::HTTPSuccess)