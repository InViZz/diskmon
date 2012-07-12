require "sinatra/base"
require "diskmon/server/harddisk"

module Diskmon
  class ServerApp < Sinatra::Base

    set :port, 7777

    post '/report/new' do
      data = request.body.read

      Kernel.puts "// Report from #{request.env['REMOTE_ADDR']}" if $DEBUG

      @m = Marshal.load(data)

      @m.each do |disk|
        report = Diskmon::HardDiskReport.create(disk.to_hash)
        report.checksum = disk.checksum

        report.print if $DEBUG

        report.save
      end

      "OK"
    end
  end
end