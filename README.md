# vagrant-puppet-modules
A [Vagrant][1] plugin to install [Puppet][2] modules on the guest machine using [Librarian-Puppet][3].

## Requirements
* Vagrant 1.1.0 or greater
* Any version of puppet installed on your guest machine (you can use the plugin [vagrant-puppet-install][4])

## Installation

```sh
vagrant plugin install vagrant-puppet-modules
```

## Usage
In your Vagrantfile, add:

```ruby
Vagrant.configure("2") do |config|
    # Version number of librarian-puppet that should be installed on your guest machine
    # config.puppet_modules.librarian_version = "1.2.0" # specific version of librarian-puppet
    config.puppet_modules.librarian_version = :latest
    
    # Path to the folder that contains your Puppetfile (relative to the Vagrantfile folder)
    config.puppet_modules.puppetfile_dir = "puppet"
end
```

This configuration will : 
* install the latest version of librarian-puppet on your guest machine
* install the puppet modules defined in "puppet/Puppetfile" in "/etc/puppet/modules" via librarian-puppet

Feel free to learn more about [Librarian-Puppet][3] to know what to put in your Puppetfile.

## Acknowledgements
A huge thanks to both [vagrant-librarian-puppet][5] and [vagrant-puppet-install][4] that inspired this plugin.

[1]: http://www.vagrantup.com
[2]: https://puppetlabs.com/
[3]: https://github.com/rodjek/librarian-puppet
[4]: https://github.com/petems/vagrant-puppet-install
[5]: https://github.com/mhahn/vagrant-librarian-puppet