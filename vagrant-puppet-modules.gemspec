# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-puppet-modules/version'

Gem::Specification.new do |spec|
  spec.name          = 'vagrant-puppet-modules'
  spec.version       = VagrantPlugins::PuppetModules::VERSION
  spec.authors       = ['Anis Safine']
  spec.email         = ['anis@poensis.fr']
  spec.description   = 'A Vagrant plugin that installs the appropriate Puppet modules on your guest machine, via' \
                       ' librarian-puppet.'
  spec.summary       = spec.description
  spec.homepage      = 'https://github.com/anis/vagrant-puppet-modules'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
end
