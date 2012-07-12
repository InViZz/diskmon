require "data_mapper"

module Diskmon
    
  class HardDiskReport
    include DataMapper::Resource

    property :dri                 , String
    property :ctl_id              , String
    property :port                , String
    property :status              , String
    property :unit                , String
    property :type                , String
    property :vendor_model        , String
    property :smart_status_raw    , String
    property :smart_status        , String
    property :size                , String
    property :reallocs            , String
    property :age_hours           , String
    property :temperature         , String
    property :serial              , String
    property :spindle_speed       , String
    property :error_events        , String
    property :member_of_zpool     , String
    property :disk_space_used     , String

    property :error_events        , String
                                     
    property :member_of_zpool     , String
    property :read_errors         , String
    property :write_errors        , String
    property :checksum_errors     , String
                                     
    property :zpool_health        , String
    property :zpool_last_command  , String
    property :zpool_total_space   , String
    property :zpool_free_space    , String
                                     
    property :system_device       , String
    property :short_device        , String

    property :created_at          , EpochTime
    property :checksum            , String, :key => true, :unique => true

    def print
      instance_variables.sort.map { |k| printf( "%-20s => %s\n", k, instance_variable_get(k) ) }    
    end

  end
end