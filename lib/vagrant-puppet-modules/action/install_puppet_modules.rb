module VagrantPlugins
    module PuppetModules
        module Action
            class InstallPuppetModules

                def initialize(app, env)
                    @app = app
                    @machine = env[:machine]
                end

                def call(env)
                    env[:ui].info "Installation of puppet modules has not been implemented yet"
                end
            end
        end
    end
end
