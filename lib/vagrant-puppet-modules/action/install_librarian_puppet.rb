module VagrantPlugins
    module PuppetModules
        module Action
            class InstallLibrarianPuppet

                def initialize(app, env)
                    @app = app
                    @machine = env[:machine]
                end

                def call(env)
                    if @machine.communicate.ready? && provision_enabled?(env)
                        @machine.config.puppet_modules.validate!

                        desired_version = @machine.config.puppet_modules.librarian_version
                        if !desired_version.nil? && installed_version != desired_version
                            env[:ui].info "Librarian-puppet needs to be either installed or updated at version #{desired_version}"
                        else
                            env[:ui].info "Librarian-puppet is installed or not required"
                        end
                    end

                    @app.call(env)
                end

                private

                def provision_enabled?(env)
                    env.fetch(:provision_enabled, true)
                end

                def windows_guest?
                    @machine.config.vm.guest.eql?(:windows)
                end

                def installed_version
                    version = nil
                    opts = nil

                    if windows_guest?
                        # todo
                    else
                        command = 'echo $(librarian-puppet --version)'
                    end

                    @machine.communicate.sudo(command, opts) do |type, data|
                        if [:stderr, :stdout].include?(type)
                            version_match = data.match(/^(.+)/)
                            version = version_match.captures[0].strip if version_match
                        end
                    end

                    version
                end
            end
        end
    end
end
