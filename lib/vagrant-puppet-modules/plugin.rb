module VagrantPlugins
    module PuppetModules
        class Plugin < Vagrant.plugin('2')
            name 'vagrant-puppet-modules'
            description <<-DESC
            This plugin installs the appropriate Puppet modules on your guest machine, via librarian-puppet.
            DESC

            VAGRANT_VERSION_REQUIREMENT = '>= 1.1.0'

            # Returns true if the Vagrant version fulfills the requirements
            #
            # @param requirements [String, Array<String>] the version requirement
            # @return [Boolean]
            def self.check_vagrant_version(*requirements)
                Gem::Requirement.new(*requirements).satisfied_by?(
                    Gem::Version.new(Vagrant::VERSION)
                )
            end

            # Verifies that the Vagrant version fulfills the requirements
            #
            # @raise [VagrantPlugins::ProxyConf::VagrantVersionError] if this plugin is incompatible with the Vagrant
            # version
            def self.check_vagrant_version!
                unless check_vagrant_version(VAGRANT_VERSION_REQUIREMENT)
                    msg = "vagrant-puppet-modules requires Vagrant version " << VAGRANT_VERSION_REQUIREMENT
                    $stderr.puts msg
                    fail msg
                end
            end

            action_hook(:install_librarian_puppet, Plugin::ALL_ACTIONS) do |hook|
                require_relative 'action/install_puppet_modules'
                require_relative 'action/install_librarian_puppet'

                hook.after(Vagrant::Action::Builtin::Provision, Action::InstallLibrarianPuppet)
                hook.after(Action::InstallLibrarianPuppet, Action::InstallPuppetModules)
            end

            check_vagrant_version!
        end
    end
end
