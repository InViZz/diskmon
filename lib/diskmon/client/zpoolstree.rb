module Diskmon

  class ZpoolsTree
    def initialize

      @disks = {}
      @pools = {}

      IO.popen("/usr/sbin/zpool status") do |zpool_status_io|

        pool_name = ''

        zpool_status_io.each_line do |l|
          case l
          
          when /pool: /
            pool_name = l.split[1]
            @pools[pool_name] = {}
            @pools[pool_name]["health"]      = `/usr/sbin/zpool get health #{pool_name} | grep #{pool_name}`.split[2]
            @pools[pool_name]["free_space"]  = `/usr/sbin/zpool get free #{pool_name} | grep #{pool_name}`.split[2]
            @pools[pool_name]["total_space"] = `/usr/sbin/zpool get allocated #{pool_name} | grep #{pool_name}`.split[2]

            history_events = []
            
            IO.popen("/usr/sbin/zpool history #{pool_name}") do |zpool_history_io|

              zpool_history_io.each_line do |l|
                case l
                when /^[0-9]/ then history_events.push(l)
                end
              end

            end

            @pools[pool_name]["last_command"] = history_events[-1].chomp

          when /c[0-9]t/
            disk_name = l.split[0]

            @disks[disk_name] = {}
            @disks[disk_name]["zpool"]           = pool_name

            @disks[disk_name]["read_errors"]     = l.split[2] 
            @disks[disk_name]["write_errors"]    = l.split[3]
            @disks[disk_name]["checksum_errors"] = l.split[4]

          end

        end
      end

      # p @disks if $DEBUG
      # p @pools if $DEBUG

    end

    def which_pool(device)
      @disks[device]["zpool"]
    end

    def read_errors(device)
      @disks[device]["read_errors"]
    end

    def write_errors(device)
      @disks[device]["write_errors"]
    end

    def checksum_errors(device)
      @disks[device]["checksum_errors"]
    end

    # free_space
    # total_space
    # last_command
    # health
    def get_pool_param(pool, param)
      @pools[pool][param]
    end

  end
end