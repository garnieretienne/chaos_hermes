require 'hermes/error'
require 'thor'

module Hermes
  
  # Hermes CLI binding.
  class CLI < Thor

    desc "create APP_NAME DOMAIN", <<-DESC
Create a new route stored in a config file and reload nginx.
DO NOT DO ANYTHING IF CONFIG FILE ALREADY EXIST.
  DESC
    method_option :nginx_conf, aliases: "-n", desc: 'full path to the main nginx config file', default: '/etc/nginx/nginx.conf'
    method_option :vhost_dir, aliases: "-d", desc: 'directory where vhosts are stored', default: '/var/nginx/routes'
    method_option :redirect, aliases: "-r", desc: 'add a redirection directive for these domains'
    method_option :alias, aliases: "-a", desc: 'add domain aliases', banner: 'ALIASES', type: :array
    method_option :upstream, aliases: "-u", desc: 'add backend servers to proxy to', banner: 'ADDRESSES', type: :array, required: true

    # Create a route, store it in a template and reload nginx gracefully.
    def create(app_name, domain)
      raise Hermes::Error.new("Your routes directory (#{options[:vhost_dir]}) is not included by the main nginx config") if !Hermes::NGINX.check_config_dir_included? options[:vhost_dir], options[:nginx_conf]
      opts = { app_name: app_name, domain: domain }
      Hermes::Route.create(opts.merge(Hash[options.map{|(k,v)| [k.to_sym,v]}])).inject
      puts "Route for #{app_name} created"
    end
  end
end