require "diskmon/version"
require "diskmon/client/config"
require "diskmon/client/raidcontroller"
require "diskmon/client/collector"

require 'sinatra'
require "thin"
require 'data_mapper'
require 'dm-validations'
require 'pp'
require "diskmon/server/harddiskreport"

module Diskmon

  module Runner

    CONFIG = "/usr/local/etc/diskmon.conf"

################################################################################
# Agent mode
################################################################################

    def self.agent

      cfg = Diskmon::Config.new(CONFIG)
      p cfg if $DEBUG

      raid_ctl = Diskmon::RaidController.new
      raid_ctl.get_all_stats
      m = raid_ctl.serialize

      coll = Diskmon::Collector.new
      send_result = coll.send_report(cfg.collector_url, cfg.collector_login, cfg.collector_password, m)
      p send_result
    end

################################################################################
# Server mode
################################################################################

    def self.server
      set :port, 7777

      DataMapper::Logger.new($stdout, :debug)
      DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/reports.db")

      $DEBUG = true

      DataMapper.finalize

      Diskmon::HardDiskReport.auto_upgrade!

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
end
