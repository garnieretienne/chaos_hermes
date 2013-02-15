require 'hermes/error'
require 'tmpdir'
require 'erb'

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
    # @option opts [String] :upstream the backend servers addresse
    # @return [Hermes::Route]
    def initialize(opts={})
      @opts = opts
      validate_presence app_name: @opts[:app_name], vhost_dir: @opts[:vhost_dir], nginx_conf: @opts[:nginx_conf], domain: @opts[:domain], upstream: @opts[:upstream]
      @tmp_path = "#{Dir.mktmpdir}/#{@opts[:app_name]}"
      @vhost_path = "#{@opts[:vhost_dir]}/#{@opts[:app_name]}"
      validate_directory @opts[:vhost_dir]
    end

    # Create a new route. Same arguments as `initialize` method.
    # Like the initialize method but write the route configuration in a config file (with a temporary path).
    #
    # @params [Hash] opts hash of parameters names and values (see `initialize` method)
    # @return [Hermes::Route]
    # @see Route#initialize Route.new
    def self.create(opts={})
      route = Hermes::Route.new opts
      route.instance_eval do
        raise Hermes::Error.new "Route for #{@opts[:app_name]} already declared" if exist?
        template 'templates/vhost.erb', @tmp_path
      end
      return route
    end

    # @todo code me
    def self.update
    end

    # @todo code me
    def self.destroy
    end

    # Load route configuration into NGiNX.
    # Copy the temporary file into the vhost_path and reload nginx gracefully.
    # Raise an error if nginx refuse the config file.
    def inject
      File.rename @tmp_path, @vhost_path
      raise Hermes::Error.new('An error occured when NGINX try to load the config file including your route, see NGINX logs (or sudo is misconfigured)') if !Hermes::NGINX.reload @opts[:nginx_conf]
      return nil
    end

    # Test if a config file for this app already exist.
    #
    # @return [Boolean]
    def exist?
      File.exist? @vhost_path
    end

    private

    # Build a file using an ERB template.
    # Use ERB's undocumented '-' (explicit trim mode).
    #
    # @param src [String] path to the ERB template file
    # @param dst [String] path to the destination file
    # @return [Boolean] return true if the file has been created, 
    #   false if nothing has been writed in the destination file.
    # @todo move to helpers
    def template(src, dst)
      template = ERB.new IO.read(src), nil, '-'
      (IO.write(dst, template.result(binding)) > 0)
    end

    # Validate presence of listed parameters.
    # Raise an error one of the given parameters has no value.
    #
    # @example Validate data
    #   data = {foo: 'hello'}
    #   validate_presence(foo: data[:foo], bar: data[bar]) #=> raise error "No bar parameter provided"
    #
    # @param [Hash] params the hash of {parameter_name: value} to verify.
    def validate_presence(params = {})
      params.each do |key, value|
        raise Hermes::Error.new("No #{key} parameter provided") if value.nil?
      end
      return nil
    end

    # Validate existance of directories.
    # Raise an error if it doesn't exist.
    #
    # @param [Array] paths Array of directory paths
    def validate_directory(*paths)
      paths.each do |path|
        File.directory? path
        raise Hermes::Error.new("The directory (#{path}) does not exist") if !File.directory? path
        raise Hermes::Error.new("The directory (#{path}) is not writable by the running user") if !File.writable? path
      end
      return nil
    end
  end
end