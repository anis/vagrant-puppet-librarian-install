module VagrantPlugins
    module PuppetModules
        module Action
            class InstallPuppetModules

                def initialize(app, env)
                    @app = app
                    @machine = env[:machine]
                end

                def call(env)
                    # do something
                end
            end
        end
    end
end
