lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'errorio/version'

Gem::Specification.new do |spec|
  spec.name          = 'errorio'
  spec.version       = Errorio::VERSION
  spec.authors       = ['Vadym Lukavyi']
  spec.email         = ['vadym.lukavyi@gmail.com']

  spec.summary       = 'Extend standart functionality of ActiveRecord errors'
  spec.homepage      = 'https://github.com/p9436/errorio'
  spec.license       = 'MIT'

  if spec.respond_to?(:metadata)
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/p9436/errorio'
    # spec.metadata['changelog_uri'] = 'TODO: Put your gem's CHANGELOG.md URL here.'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rubocop', '~> 12.0'
end
