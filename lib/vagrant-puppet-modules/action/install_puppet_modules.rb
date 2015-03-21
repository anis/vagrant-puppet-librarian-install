module VagrantPlugins
    module PuppetModules
        module Action
            class InstallPuppetModules

                def initialize(app, env)
                    @app = app
                    @machine = env[:machine]
                    @logger = Log4r::Logger.new('vagrantplugins::puppet_modules::action::installmodules')
                end

                def call(env)
                    if @machine.communicate.ready? && provision_enabled?(env)
                        if @machine.config.puppet_modules.puppetfile_dir.nil?
                            env[:ui].info "Puppetfile is not defined, puppet modules won't be installed"
                            return
                        end

                        install_modules(env)
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

                def install_modules(env)
                    msg = "Installing puppet modules via librarian"
                    env[:ui].info(msg)
                    @logger.info(msg)

                    @puppetfile_path = File.join(
                        env[:root_path],
                        @machine.config.puppet_modules.puppetfile_dir,
                        "Puppetfile"
                    )

                    if !File.file?(@puppetfile_path)
                        msg = "The file '" << @puppetfile_path << "' does not exist"
                        @logger.error(msg)
                        env[:ui].info msg

                        return
                    end

                    @machine.communicate.tap do |comm|
                        comm.upload(@puppetfile_path, "Puppetfile")

                        if windows_guest?
                            # todo
                        else
                            install_cmd = "librarian-puppet install --path=/etc/puppet/modules"
                        end

                        comm.sudo(install_cmd) do |type, data|
                            if [:stderr, :stdout].include?(type)
                                next if data =~ /stdin: is not a tty/
                                env[:ui].info(data)
                            end
                        end
                    end
                end
            end
        end
    end
end
