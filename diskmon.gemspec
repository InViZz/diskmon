# -*- encoding: utf-8 -*-
require File.expand_path('../lib/diskmon/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Morion Black"]
  gem.email         = ["morion.estariol@gmail.com"]
  gem.description   = %q{Gem for collect statistic from disks}
  gem.summary       = %q{Gem for collect statistic from disks}
  gem.homepage      = ""

  gem.files         = ["Gemfile", "LICENSE", "README.md", "Rakefile", "bin/diskmon", "diskmon.gemspec", "lib/diskmon.rb", "lib/diskmon/client/collector.rb", "lib/diskmon/client/config.rb", "lib/diskmon/client/harddisk.rb", "lib/diskmon/client/raidcontroller.rb", "lib/diskmon/client/solarismapdev.rb", "lib/diskmon/client/zpoolstree.rb", "lib/diskmon/server/harddisk.rb", "lib/diskmon/server/serverapp.rb", "lib/diskmon/server/harddiskreport.rb", "lib/diskmon/version.rb"]
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "diskmon"
  gem.require_paths = ["lib"]
  gem.version       = Diskmon::VERSION
  gem.add_runtime_dependency 'data_mapper'
  gem.add_runtime_dependency 'sinatra'
#  gem.add_runtime_dependency 'thin'
gem.add_runtime_dependency 'dm-sqlite-adapter'
end
