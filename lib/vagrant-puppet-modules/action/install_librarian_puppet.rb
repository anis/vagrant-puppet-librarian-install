require 'shellwords'
require 'vagrant/util/downloader'

module VagrantPlugins
    module PuppetModules
        module Action
            class InstallLibrarianPuppet

                def initialize(app, env)
                    @app = app
                    @machine = env[:machine]
                    @logger = Log4r::Logger.new('vagrantplugins::puppet_modules::action::installlibrarian')
                end

                def call(env)
                    if @machine.communicate.ready? && provision_enabled?(env)
                        @machine.config.puppet_modules.validate!

                        desired_version = @machine.config.puppet_modules.librarian_version
                        if desired_version.nil? || installed_version == desired_version
                            env[:ui].info "Librarian-puppet is installed or not required"
                            return
                        end

                        fetch_or_create_install_script(env)
                        install(desired_version, env)
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

                def fetch_or_create_install_script(env)
                    @script_tmp_path = env[:tmp_path].join("#{Time.now.to_i.to_s}-#{install_script_name}")

                    msg = "Generating install script at: #{@script_tmp_path}"
                    env[:ui].info(msg)
                    @logger.info(msg)

                    url = find_install_script

                    begin
                        if windows_guest?
                            # todo
                        else
                            downloader = Vagrant::Util::Downloader.new(url, @script_tmp_path, {})
                            downloader.download!
                        end
                    rescue Vagrant::Errors::DownloaderInterrupted
                        msg = 'The download of the librarian-puppet install script was interrupted'
                        env[:ui].info(msg)
                        @logger.info(msg)
                        return
                    end
                end

                def find_install_script
                    config_install_url || default_install_url
                end

                def config_install_url
                    @machine.config.puppet_modules.install_url
                end

                def default_install_url
                    if windows_guest?
                        # todo
                    else
                        'https://raw.githubusercontent.com/anis/vagrant-puppet-modules/master/shell/librarian_puppet_install.sh'
                    end
                end

                def install_script_name
                    if windows_guest?
                        # todo
                    else
                        'librarian_puppet_install.sh'
                    end
                end

                def install(version, env)
                    msg = "Installing librarian-puppet at version #{version}"
                    env[:ui].info(msg)
                    @logger.info(msg)

                    shell_escaped_version = Shellwords.escape(version)

                    @machine.communicate.tap do |comm|
                        comm.upload(@script_tmp_path, install_script_name)

                        if windows_guest?
                            # todo
                        else
                            install_cmd = "sh #{install_script_name}"
                            install_cmd << " -v #{version}"
                            install_cmd << ' 2>&1'
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
