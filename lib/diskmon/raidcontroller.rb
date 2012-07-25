require "diskmon/solarismapdev"
require "diskmon/harddisk"
require "diskmon/zpoolstree"

module Diskmon

  class RaidController

    def initialize
      @vendor  = get_vendor
      @disks   = []
    end

    def get_vendor
      v = `scanpci | egrep -i '(Adaptec|3ware)'`

      case v.downcase
      when /3ware/   then return :threeware
      when /adaptec/ then return :adaptec
      else 
        return nil
      end
    end

    def get_ctl_ids

      ctl_ids = []

      case @vendor
      
      when :threeware
        IO.popen("tw_cli show | grep ^c") do |tw_cli_show_io|
          tw_cli_show_io.each_line { |l| ctl_ids.push( l.split[0] ) }
        end
      when :adaptec
        IO.popen("arcconf getversion | grep 'Controller #'") do |arcconf_getversion_io|
          arcconf_getversion_io.each_line { |l| ctl_ids.push( l.split[1][1..-1] ) }
        end
      
      end

      ctl_ids
    end

    def get_ctl_disks_info(ctl_id)
      case @vendor
      when :threeware

        mapdev = Diskmon::SolarisMapDev.new

        # disks overview
        #
        IO.popen("tw_cli /#{ctl_id} show drivestatus | grep ^p") do |tw_cli_drives_io|
          tw_cli_drives_io.each_line do |l|
            l_arr = l.split

            d = Diskmon::HardDisk.new

            d.ctl_id       = ctl_id[1..-1]   # strip 'c'
            d.port         = l_arr[0][1..-1] # strip 'p'
            d.status       = l_arr[1]
            d.unit         = l_arr[2][1..-1] # strip 'u'
            d.size         = l_arr[3..4]
            d.type         = l_arr[5]
            d.vendor_model = l_arr[8]

            d.dri = "disk://" + Diskmon::Server.get_id + "/" + d.ctl_id + "/" + d.port

            IO.popen("tw_cli /c#{d.ctl_id}/p#{d.port} show all | grep '^/c#{d.ctl_id}/p#{d.port}'") do |tw_cli_show_all_io|

              tw_cli_show_all_io.each_line do |l|

                params_arr = l.split

                case params_arr[1]
                  when "Reallocated" then d.reallocs      = params_arr[4]
                  when "Power"       then d.age_hours     = params_arr[5]
                  when "Temperature" then d.temperature   = params_arr[3]
                  when "Serial"      then d.serial        = params_arr[3]
                  when "Spindle"     then d.spindle_speed = params_arr[4]
                end
              end

            end # show all

            d.system_device   = "c#{d.ctl_id}t#{d.port}d0"
            d.short_device    = mapdev.to_short(d.system_device)
            
            yield d
          end
        end

      when :adaptec
        mapdev = Diskmon::SolarisMapDev.new

        # disks overview
        #
        arcconf_num_drives = `arcconf getconfig #{ctl_id} | grep 'Device #' | wc -l`.chomp.to_i

        0.upto(arcconf_num_drives - 2) do |num|
          disk = get_hash_of_disk(ctl_id, num) 

          d = Diskmon::HardDisk.new

          d.ctl_id       = ctl_id
          d.port         = disk["ReportedLocation"].split("Slot")[1]
          d.status       = disk["State"]
          d.size         = disk["Size"]
          d.type         = disk["TransferSpeed"]
          d.vendor_model = disk["Model"]
          d.serial       = disk["Serialnumber"]

          d.dri = "disk://" + Diskmon::Server.get_id + "/" + d.ctl_id + "/" + d.port

          # TODO smart status
          if `iostat -En | ggrep #{d.serial} -B1`.split[0]
            d.system_device = `iostat -En | ggrep #{d.serial} -B1`.split[0]
          else 
            d.system_device = "c0t#{d.port}d0"
          end

          d.short_device = mapdev.to_short(d.system_device)
          
          yield d
        end
      end
    end

    def get_hash_of_disk(ctl_id, num)
      disk_info = []
      d = []
      get_config = `arcconf getconfig #{ctl_id} | ggrep -m 1 'Device ##{num}' -A 22`
      get_config.split(/\n/).each do |e|
        disk_info << e.split(' :')
      end
      disk_info.slice!(0,2)
      disk_info.flatten!
      disk_info.each do |e|
        d << e.split(" ").join
      end
      disk_hash = Hash[*d] 
    end

    def get_all_stats

      ctl_ids = get_ctl_ids

      zp = Diskmon::ZpoolsTree.new

      if not ctl_ids.empty?
        ctl_ids.each do |ctl_id|
          get_ctl_disks_info(ctl_id) do |d| 

            d.member_of_zpool = zp.which_pool(d.system_device)
            d.read_errors     = zp.read_errors(d.system_device)
            d.write_errors    = zp.write_errors(d.system_device)
            d.checksum_errors = zp.checksum_errors(d.system_device)

            d.zpool_health       = zp.get_pool_param(d.member_of_zpool, "health")
            d.zpool_last_command = zp.get_pool_param(d.member_of_zpool, "last_command")
            d.zpool_total_space  = zp.get_pool_param(d.member_of_zpool, "total_space")
            d.zpool_free_space   = zp.get_pool_param(d.member_of_zpool, "free_space")

            @disks.push(d)
          end
        end
      end

      # TODO: /c3 show events

      p @disks if $DEBUG

    end

    def parse_smart_status(smart_arr)

      # TODO: dig smartmontools sources

      smart_attributes = {
        '00' => 'Zero_Field',
        '01' => 'Raw_Read_Error_Rate',
        '03' => 'Spin_Up_Time',
        '04' => 'Start_Stop_Count',
        '05' => 'Reallocated_Sector_Ct',
        '07' => 'Seek_Error_Rate',
        '09' => 'Power_On_Hours',
        '0A' => 'Spin_Retry_Count',
        '0B' => 'Calibration_Retry_Count',
        '0C' => 'Power_Cycle_Count',
        'B8' => 'End-to-End_error',
        'BB' => 'Reported_Uncorrect',
        'BC' => 'Command_Timeout',
        'BD' => 'High Fly Writes',
        'BE' => 'Airflow Temperature',
        'C0' => 'Power-off_Retract_Count',
        'C1' => 'Load_Cycle_Count',
        'C2' => 'Temperature',
        'C3' => 'Hardware ECC Recovered',
        'C4' => 'Reallocation Event Count',
        'C5' => 'Current Pending Sector Count',
        'C6' => 'Uncorrectable Sector Count',
        'C7' => 'UltraDMA CRC Error Count',
        'C8' => 'Multi-Zone Error Rate',
      }

      smart_parsed = {}

      i = 0 ; while i < 360 do

          if smart_arr[i+2].to_i != 0
      
            j = 0 ; while j < 12 do
              if j == 0
                smart_param = smart_attributes[smart_arr[i+j+2]]
                smart_val = ''
              end

                if j > 4 and j < 11
                smart_val << smart_arr[i+j+2]
              end

              j += 1
            end # while j < 12

            smart_parsed["#{smart_param}"] = smart_val.to_i(10)
                      
          end # if smart_arr
          
          i += 12

      end # while i

  #    p smart_parsed if $DEBUG

      smart_parsed

    end

    def serialize
      Marshal.dump(@disks)
    end

    private :get_vendor
    private :get_ctl_ids
    private :get_ctl_disks_info

  end

  ########## Server

  module Server

    # def get_id
    #   Socket.gethostname.downcase    
    # end

    def self.get_id
      `/usr/sbin/zlogin df-storage hostname`.chomp
    end
  end
end