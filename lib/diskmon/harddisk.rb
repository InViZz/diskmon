module Diskmon

  class HardDisk

    # TODO: convert to bytes
    # def size(size)
    #   @size = 
    # end

    attr_accessor :dri
    attr_accessor :ctl_id
    attr_accessor :port
    attr_accessor :status
    attr_accessor :unit
    attr_accessor :type             # sata or sas or jbod
    attr_accessor :vendor_model
    attr_accessor :smart_status_raw # array of hex numbers
    attr_accessor :smart_status
    attr_accessor :size

    attr_accessor :reallocs
    attr_accessor :age_hours
    attr_accessor :temperature
    attr_accessor :serial
    attr_accessor :spindle_speed    # rpms

    attr_accessor :error_events

    attr_accessor :member_of_zpool
    attr_accessor :read_errors
    attr_accessor :write_errors
    attr_accessor :checksum_errors

    attr_accessor :zpool_health
    attr_accessor :zpool_last_command
    attr_accessor :zpool_total_space
    attr_accessor :zpool_free_space

    attr_accessor :system_device
    attr_accessor :short_device

  end
end