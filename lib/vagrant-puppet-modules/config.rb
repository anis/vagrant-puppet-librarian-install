require 'log4r'
require 'rubygems/dependency'
require 'rubygems/dependency_installer'

module VagrantPlugins
    module PuppetModules
        class Config < Vagrant.plugin('2', :config)
            attr_accessor :librarian_version

            def initialize
                @librarian_version = UNSET_VALUE
                @logger = Log4r::Logger.new('vagrantplugins::puppet_modules::config')
            end

            def finalize!
                if @librarian_version == UNSET_VALUE
                    @librarian_version = nil
                elsif @librarian_version.to_s == 'latest'
                    @librarian_version = retrieve_latest_librarian_version
                end
            end

            def validate!()
                finalize!

                if !librarian_version.nil? && !valid_librarian_version?(librarian_version)
                    errors = Vagrant::Util::TemplateRenderer.render(
                        'config/validation_failed',
                        errors: {
                            'vagrant-puppet-modules' => [
                                "#{librarian_version} is not a valid version of librarian-puppet."
                            ]
                        }
                    )
                    fail Vagrant::Errors::ConfigInvalid, errors: errors
                end
            end

            private

            def retrieve_latest_librarian_version
                available_gems = dependency_installer.find_gems_with_sources(librarian_gem_dependency)

                spec, _source =
                if available_gems.respond_to?(:last)
                    spec_with_source = available_gems.last
                    spec_with_source
                else
                    available_gems.pick_best!
                    best_gem = available_gems.set.first
                    best_gem && [best_gem.spec, best_gem.source]
                end

                spec && spec.version.to_s
            end

            def valid_librarian_version?(version)
                is_valid = false
                begin
                    available = dependency_installer.find_gems_with_sources(librarian_gem_dependency(version))
                    is_valid = true unless available.empty?
                rescue ArgumentError => e
                    @logger.debug("#{version} is not a valid librarian-puppet version: #{e}")
                end

                is_valid
            end

            def dependency_installer
                @dependency_installer ||= Gem::DependencyInstaller.new
            end

            def librarian_gem_dependency(version = nil)
                Gem::Dependency.new('librarian-puppet', version)
            end
        end
    end
end