require "net/http"

module Diskmon
  
  class Collector

    def send_report(url, login, password, dump)
      c_uri = URI(url)

      p c_uri if $DEBUG

      c_req = Net::HTTP::Post.new(c_uri.path)
      c_req.basic_auth(login, password)
      c_req.body = dump
      c_req.content_type = 'text/plain'

      res = Net::HTTP.start(c_uri.host, c_uri.port) do |http|
        http.request(c_req)
      end

      res.code
    end
  end
end