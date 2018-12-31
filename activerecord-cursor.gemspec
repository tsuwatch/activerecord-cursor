lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'activerecord/cursor/version'

Gem::Specification.new do |spec|
  spec.name          = 'activerecord-cursor'
  spec.version       = ActiveRecord::Cursor::VERSION
  spec.authors       = ['Tomohiro Suwa']
  spec.email         = ['neoen.gsn@gmail.com']

  spec.summary       = 'pagination using cursors for ActiveRecord'
  spec.description   = 'pagination using cursors for ActiveRecord'
  spec.homepage      = 'https://github.com/tsuwatch/activerecord-curosr'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord'

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'sqlite3'
end
