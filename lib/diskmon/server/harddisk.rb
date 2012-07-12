require 'digest'

module Diskmon
  
  class HardDisk

    # credit: http://stackoverflow.com/a/5031637
    def to_hash
      Hash[instance_variables.map { |var| [var[1..-1].to_sym, instance_variable_get(var)] }]
    end

    def checksum
      as_str = ''
      instance_variables.sort.map { |k| as_str << "#{k}=#{instance_variable_get(k)};" }
      p as_str if $DEBUG
      Digest::MD5.hexdigest(as_str)
    end
  end
end