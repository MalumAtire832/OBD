
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'OBD/version'

Gem::Specification.new do |spec|
  spec.name          = "OBD"
  spec.version       = OBD::VERSION
  spec.authors       = ["Harjan Knapper"]
  spec.email         = ["harjan@knapper-development.nl"]

  spec.summary       = %q{A gem for connecting to a OBD device via serialport, wifi, or bluetooth.}
  spec.description   = %q{OBD is a gem that can be used to connect to a car's OBD interface.
                          The gem is currently in alpha, but some features are already working.}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "GPL-3.0"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  # spec.files         = `git ls-files -z`.split("\x0").reject do |f|
  #   f.match(%r{^(test|spec|features)/})
  # end

  # noinspection RubyLiteralArrayInspection
  spec.files = [
      'lib/OBD/version.rb',
      'lib/OBD.rb',
      'lib/OBD/connection.rb',
      'lib/OBD/controller.rb',
      'lib/OBD/conversion.rb',
      'lib/OBD/error.rb',
      'lib/OBD/mode.rb',
      'lib/OBD/parser.rb',
      'lib/OBD/requester.rb',
      'lib/OBD/modes/mode_01.rb',
  ]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "serialport", "~> 1.3"
  spec.add_development_dependency "yard", "~> 0.9.12"
  spec.add_development_dependency "awesome_print", "~> 1.8.0"

  spec.add_runtime_dependency "serialport", "~> 1.3"
  spec.add_runtime_dependency "awesome_print", "~> 1.8.0"
end
