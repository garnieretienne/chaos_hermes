require 'hermes/helpers/utils'
require 'hermes/error'
require 'hermes/nginx'
require 'tmpdir'

module Hermes

  # This class manage route creation and deletion.
  # The route are converted to nginx config files stored in a dedicated directory.
  # This directory must be source by the nginx configuration to be effective.
  class Route

    # Build a new route using an application name and a main domain.
    # Parameters are passed using a _Hash_ of names and values.
    #
    # @param [Hash] opts hash of parameters names and values
    # @option opts [String] :app_name the app name
    # @option opts [String] :vhost_dir the directory where route config files are stored
    # @option opts [String] :nginx_conf the main nginx configuration file
    # @option opts [String] :domain the main domain attached to the application
    # @option opts [String] :upstream the backend server addresses
    # @return [Hermes::Route]
    def initialize(opts={})
      @opts = opts
      Hermes::Helpers::Utils.validate_params :presence, app_name: @opts[:app_name], vhost_dir: @opts[:vhost_dir], nginx_conf: @opts[:nginx_conf], domain: @opts[:domain], upstream: @opts[:upstream]
      Hermes::Helpers::Utils.validate_params :directory_writable?, vhost_dir: @opts[:vhost_dir]
      @tmp_path = "#{Dir.mktmpdir}/#{@opts[:app_name]}"
      @vhost_path = "#{@opts[:vhost_dir]}/#{@opts[:app_name]}"
    end

    # Update an existing route. Same options as `initialize` method.
    # Erase the old route config file (if exist) and create a new one.
    #
    # @param [Hash] opts hash of parameters names and values (see `initialize` method)
    # @return [Hermes::Route]
    # @see Route#initialize initialize
    def self.update(opts = {})
      route = Hermes::Route.new opts
      route.instance_eval do
        Hermes::Helpers::Utils.template binding, "#{File.dirname(__FILE__)}/../../templates/vhost.erb", @tmp_path
      end
      return route
    end

    # Alias create and update methods
    class << self 
      alias_method :create, :update
    end

    # Delete an existing route.
    # Erase the old route config file and reload NGINX.
    # Raise an error if the route doesn't exist.
    #
    # @param [Hash] opts hash of parameters names and values
    # @option param [String] app_name name of the app
    # @option param [String] route config file directory path
    # @option param [String] main nginx config file
    def self.destroy(opts = {})
      Hermes::Helpers::Utils.validate_params :presence, app_name: opts[:app_name], vhost_dir: opts[:vhost_dir], nginx_conf: opts[:nginx_conf]
      Hermes::Helpers::Utils.validate_params :directory_writable?, vhost_dir: opts[:vhost_dir]
      vhost_path = "#{opts[:vhost_dir]}/#{opts[:app_name]}"
      raise Hermes::Error.new "Route for '#{opts[:app_name]}' can't be deleted (#{vhost_path} config file doen't exist)" if !File.exist? vhost_path
      File.delete vhost_path
    end

    # List all app currently routed.
    # List all app having a vhost config file in the vhost directory.
    #
    # @param [Hash] opts hash of parameters names and values
    # @option param [String] route config file directory path
    # @return [Array] apps list of apps having routing rules
    def self.list(opts = {})
      Hermes::Helpers::Utils.validate_params :presence, vhost_dir: opts[:vhost_dir]
      Hermes::Helpers::Utils.validate_params :directory_writable?, vhost_dir: opts[:vhost_dir]
      Dir.entries(opts[:vhost_dir]).delete_if {|e| (e == '..' || e == '.')}
    end

    # Load route configuration into NGiNX.
    # Copy the temporary file into the vhost_path and reload nginx gracefully.
    # Raise an error if nginx refuse the config file.
    def inject
      File.rename @tmp_path, @vhost_path
      raise Hermes::Error.new('An error occured when NGINX try to load the config file including your route, see NGINX logs (or sudo is misconfigured)') if !Hermes::NGINX.reload @opts[:nginx_conf]
      return 0
    end

    # Test if a config file for this app already exist.
    #
    # @return [Boolean]
    def exist?
      File.exist? @vhost_path
    end

    # Validate given parameters.
    #
    # @example Validate params presence
    #   data = {foo: 'hello', path: '/not/a/directory'}
    #   validate_params :presence, foo: data[foo], bar: data[:bar]  #=> raise error "No bar parameter provided"
    #   validate_params :directory_writable?                        #=> raise error "The directory (/not/a/directory) doesn't exist"
    #
    # @param [Symbol] validation the validation type
    #   Validations types:
    #   * :presence if a params is present or not (not nil)
    #   * :directory_writable? if a directory exist and is writable by the current user
    # @param [Hash] parameters the parameters to validate
    def self.validate_params(validation = :presence, params = {})
      case validation
      when :presence
        params.each do |key, value|
          raise Hermes::Error.new("No #{key} parameter provided") if value.nil?
        end
      when :directory_writable?
        params.each do |name, path|
          File.directory? path
          raise Hermes::Error.new("The directory (#{path}) doesn't exist") if !File.directory? path
          raise Hermes::Error.new("The directory (#{path}) is not writable by the running user") if !File.writable? path
        end
      else
        raise Hermes::Error.new("Unknow validation type (#{validation})")
      end
      return 0
    end
  end
end
