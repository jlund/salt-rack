salt-rack
=========

 Sample Rack application [Salt](http://saltstack.com/) States that will install Nginx, Passenger, Ruby 1.9.3 + the [Falcon patch](https://gist.github.com/funny-falcon/4755042). They also demonstrate how to deploy a [sample Rack application](https://github.com/jlund/imgur-display) using git.

 Specifically, these states do the following:

 * Install a few crucial packages like git and NTP
 * Create a deploy user that the application files will belong to
 * Add an SSH public key to the deploy user's Authorized Keys file
 * Reconfigure OpenSSH to only allow access via SSH keys
 * Install Ruby 1.9.3 + the Falcon patch
 * Install Bundler
 * Install Nginx + Passenger
 * Set up and enable an Nginx vhost
 * Create all necessary application directories
 * Use git to checkout the latest revision of the [imgur-display](https://github.com/jlund/imgur-display) codebase
 * Create required symlinks
 * Use bundler to install all Gem dependencies

Running these states will leave you with a fully-functional Rack application server that is ready to show you a random picture from imgur. With some incredibly minor adjustments, these states will deploy your own application! It's my hope that they will be helpful to anyone who needs to set up a similar server using Salt.

A cloudinit template is also included that you can use to automatically provision Salt on a new Ubuntu server.

These states were tested on Ubuntu 12.04.2 LTS but should also work on Debian 7.

Enjoy!
