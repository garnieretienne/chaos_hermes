require 'hermes/error'
require 'thor'

module Hermes
  
  # Hermes CLI binding.
  class CLI < Thor
    class_option :nginx_conf, aliases: "-n", desc: 'full path to the main nginx config file', default: '/etc/nginx/nginx.conf'
    class_option :vhost_dir, aliases: "-d", desc: 'directory where vhosts are stored', default: '/var/nginx/routes'


    desc "create APP_NAME DOMAIN", <<-DESC
Create a new route stored in a config file and reload nginx.
DO NOT DO ANYTHING IF THE ROUTE CONFIG FILE ALREADY EXIST.
    DESC
    method_option :redirect, aliases: "-r", desc: 'add a redirection directive for these domains'
    method_option :alias, aliases: "-a", desc: 'add domain aliases', banner: 'ALIASES', type: :array
    method_option :upstream, aliases: "-u", desc: 'add backend servers to proxy to', banner: 'ADDRESSES', type: :array, required: true

    # Create a route, store it in a template and reload nginx gracefully.
    def create(app_name, domain)
      # verify_route_directory_is_included_in_nginx_conf
      opts = { app_name: app_name, domain: domain }
      Hermes::Route.create(opts.merge(Hash[options.map{|(k,v)| [k.to_sym,v]}])).inject
      puts "Route for #{app_name} created"
    end

    desc "update APP_NAME DOMAIN", <<-DESC
Update a route re-creating a new config file and reloading nginx.
DO NOT DO ANYTHING IF THE ROUTE CONFIG FILE DOESN'T EXIST YET.
    DESC
    method_option :redirect, aliases: "-r", desc: 'add a redirection directive for these domains'
    method_option :alias, aliases: "-a", desc: 'add domain aliases', banner: 'ALIASES', type: :array
    method_option :upstream, aliases: "-u", desc: 'add backend servers to proxy to', banner: 'ADDRESSES', type: :array, required: true

    # Update an existing route by removing the old config file, 
    # creating a new config file from scratch and reload NGINX.
    def update(app_name, domain)
      # verify_route_directory_is_included_in_nginx_conf
      opts = { app_name: app_name, domain: domain }
      Hermes::Route.update(opts.merge(Hash[options.map{|(k,v)| [k.to_sym,v]}])).inject
      puts "Route for #{app_name} updated"
    end

    desc "destroy APP_NAME", <<-DESC
Delete an existing route config file and reload nginx.
    DESC

    # Delete an existing route by removing the associed config file and reloading NGINX.
    def destroy(app_name)
      # verify_route_directory_is_included_in_nginx_conf
      opts = { app_name: app_name }
      Hermes::Route.destroy(opts.merge(Hash[options.map{|(k,v)| [k.to_sym,v]}]))
      puts "Route for #{app_name} deleted"
    end

    desc "list", <<-DESC
List all app currently routed.
    DESC

    # Delete an existing route by removing the associed config file and reloading NGINX.
    def list
      # verify_route_directory_is_included_in_nginx_conf
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

    private

    # Verify the directory storing route config file is included somewhere in the nginx config file.
    # Raise an error if the directory path is not found.
    def verify_route_directory_is_included_in_nginx_conf
      raise Hermes::Error.new("Your routes directory (#{options[:vhost_dir]}) is not included by the main nginx config") if !Hermes::NGINX.check_config_dir_included? options[:vhost_dir], options[:nginx_conf]
    end

    def route_options
      method_option :nginx_conf, aliases: "-n", desc: 'full path to the main nginx config file', default: '/etc/nginx/nginx.conf'
      method_option :vhost_dir, aliases: "-d", desc: 'directory where vhosts are stored', default: '/var/nginx/routes'
      method_option :redirect, aliases: "-r", desc: 'add a redirection directive for these domains'
      method_option :alias, aliases: "-a", desc: 'add domain aliases', banner: 'ALIASES', type: :array
      method_option :upstream, aliases: "-u", desc: 'add backend servers to proxy to', banner: 'ADDRESSES', type: :array, required: true
    end
  end
end
