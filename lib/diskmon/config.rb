require "yaml"

module Diskmon
  
  class Config

    def initialize(filepath)
      h = YAML.load_file(filepath)
      @collector_url      = h["collector_url"]
      @collector_login    = h["collector_login"]
      @collector_password = h["collector_password"]
    end

    attr_reader :collector_url
    attr_reader :collector_login
    attr_reader :collector_password

  end
end