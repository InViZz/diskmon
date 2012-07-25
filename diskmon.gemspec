# -*- encoding: utf-8 -*-
require File.expand_path('../lib/diskmon/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Morion Black"]
  gem.email         = ["morion.estariol@gmail.com"]
  gem.description   = %q{Gem for collect statistic from disks}
  gem.summary       = %q{Gem for collect statistic from disks}
  gem.homepage      = ""

  gem.files         = ["Gemfile", "LICENSE", "README.md", "Rakefile", "bin/diskmon", "diskmon.gemspec", "lib/diskmon.rb", "lib/diskmon/collector.rb", "lib/diskmon/config.rb", "lib/diskmon/harddisk.rb", "lib/diskmon/raidcontroller.rb", "lib/diskmon/solarismapdev.rb", "lib/diskmon/zpoolstree.rb", "lib/diskmon/version.rb"]
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "diskmon"
  gem.require_paths = ["lib"]
  gem.version       = Diskmon::VERSION

end
