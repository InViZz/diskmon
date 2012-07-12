module Diskmon

  class SolarisMapDev

    def initialize

      @full_dev_to_inst = {}

      # "/pci@7a,0/pci8086,340c@5/pci9005,2b5@0/disk@52,0" 11 "sd"
      IO.foreach("/etc/path_to_inst") do |l|
        case l.strip
        when /"sd"$/
          full_dev = l.split[0].tr('"','')
          idx      = l.split[-2]
          @full_dev_to_inst[full_dev] = "sd#{idx}"
        end
      end
    end

    def to_short(device)
      begin
        dev = File.readlink("/dev/rdsk/#{device}").gsub("../../devices", "").split(':')[0]
      rescue Errno::ENOENT
        dev = File.readlink("/dev/rdsk/#{device}s0").gsub("../../devices", "").split(':')[0]
      end

      @full_dev_to_inst[dev]
    end

  end
end