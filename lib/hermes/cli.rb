require 'hermes/error'
require 'thor'

module Hermes
  
  # Hermes CLI binding.
  class CLI < Thor
    class_option :nginx_conf, aliases: "-n", desc: 'full path to the main nginx config file', default: '/etc/nginx/nginx.conf'
    class_option :vhost_dir, aliases: "-d", desc: 'directory where vhosts are stored', default: '/var/nginx/routes'


    desc "create APP_NAME DOMAIN", <<-DESC
Create a new route stored in a config file and reload nginx.
Alias for update command.
    DESC
    method_option :redirect, aliases: "-r", desc: 'add a redirection directive for these domains'
    method_option :alias, aliases: "-a", desc: 'add domain aliases', banner: 'ALIASES', type: :array
    method_option :upstream, aliases: "-u", desc: 'add backend servers to proxy to', banner: 'ADDRESSES', type: :array, required: true

    alias_method :create, :update

    desc "update APP_NAME DOMAIN", <<-DESC
Update a route re-creating a new config file and reloading nginx.
    DESC
    method_option :redirect, aliases: "-r", desc: 'add a redirection directive for these domains'
    method_option :aliases, aliases: "-a", desc: 'add domain aliases', banner: 'ALIASES', type: :array
    method_option :upstream, aliases: "-u", desc: 'add backend servers to proxy to', banner: 'ADDRESSES', type: :array, required: true

    # Update an existing route by removing the old config file, 
    # creating a new config file from scratch and reload NGINX.
    def update(app_name, domain)
      opts = { app_name: app_name, domain: domain }
      Hermes::Route.update(opts.merge(Hash[options.map{|(k,v)| [k.to_sym,v]}])).inject
      puts "Route for #{app_name} updated"
    end

    desc "destroy APP_NAME", <<-DESC
Delete an existing route config file and reload nginx.
    DESC

    # Delete an existing route by removing the associed config file and reloading NGINX.
    def destroy(app_name)
      opts = { app_name: app_name }
      Hermes::Route.destroy(opts.merge(Hash[options.map{|(k,v)| [k.to_sym,v]}]))
      puts "Route for #{app_name} deleted"
    end

    desc "list", <<-DESC
List all app currently routed.
    DESC

    # Delete an existing route by removing the associed config file and reloading NGINX.
    def list
      apps = Hermes::Route.list(Hash[options.map{|(k,v)| [k.to_sym,v]}])
      if !apps.empty?
        puts "Apps:"
        apps.each do |app|
          puts " - #{app}"
        end
      else
        puts "No apps routed"
      end
    end
  end
end
