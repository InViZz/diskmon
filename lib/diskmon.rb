require "diskmon/version"
require "diskmon/config"
require "diskmon/raidcontroller"
require "diskmon/collector"

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
  end
end
