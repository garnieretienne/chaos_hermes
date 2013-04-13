require 'hermes/helpers'
require 'hermes/error'
require 'open3'

module Hermes

  class NGINX

    # `nginx` command name
    NGINX_CMD   = 'nginx'

    # Arguments to reload nginx gracefully using `nginx` command.
    RELOAD_ARGS = '-s reload'

    # Ensure nginx reload command can be executed by the current user using sudo with no password.
    # Raise an error if the `nginx` command is not installed for the current user.
    # Raise an error if the nginx reload command is not declared in the sudo configuration.
    def self.check_dependencies
      full_command_path = Hermes::Helpers::System.which NGINX_CMD
      raise Hermes::Error.new("'nginx' command is not available nor executable by the current user") if full_command_path == ""
      raise Hermes::Error.new("This user has no right to run the command '#{full_command_path} #{RELOAD_ARGS} -c *' as sudo without password") if !Hermes::Helpers::Sudo.granted? "#{full_command_path} #{RELOAD_ARGS} -c"
      return nil
    end

    # Check if a directory is included in the main config file.
    # Parse the nginx config file to check if the given directory path is included somewhere.
    #
    # @return [Boolean]
    def self.check_config_dir_included?(dir_path, nginx_conf_file)
      verify_nginx_conf_exist nginx_conf_file
      stdin, stdout, stderr, wait_thr = Open3.popen3 "cat #{nginx_conf_file} | grep #{dir_path}"
      (wait_thr.value.to_i == 0)
    end

    # Verify the specified config file exist.
    # Raise an error if the given file doesn't exist.
    def self.verify_nginx_conf_exist(nginx_conf_file)
      raise Hermes::Error.new("The specified file (#{nginx_conf_file}) do not exist") if !File.exist? nginx_conf_file
      return nil
    end

    # Reload nginx safely (test the configuration file and gracefully reload nginx).
    #
    # @return [Boolean] return true if nginx command exit with a 0 exit status or false otherwise
    def self.reload(nginx_conf_file)
      verify_nginx_conf_exist nginx_conf_file
      exit_status, stdout, stderr = Hermes::Helpers::Sudo.run "#{NGINX_CMD} #{RELOAD_ARGS} -c #{nginx_conf_file}"
      (exit_status == 0)
    end
  end
end
