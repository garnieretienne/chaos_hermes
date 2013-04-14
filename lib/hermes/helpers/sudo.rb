require 'hermes/helpers/system'
require 'hermes/error'
require 'open3'

module Hermes

  module Helpers

    # This class contains helpers related to the `sudo` unit utility.
    class Sudo

      # Is sudo supported in the running system ?
      @@supported = false
  
      # Check if the `sudo` command is present on the current system.
      #
      # @return [Boolean]
      def self.support?
        @@supported ||= (Hermes::Helpers::System.which('sudo') != '')
      end

      # Verify The exact given command can be run by the current user using sudo with no password.
      # This method parse the `sudo --list` output and try to find the command.
      #
      # @param [String] cmd the command to be checked
      # @return [Boolean]
      def self.granted?(cmd)
        raise Hermes::Error.new("'sudo' command is not installed or useable by the current user") if !Hermes::Helpers::Sudo.support?
        stdin, stdout, stderr, wait_thr = Open3.popen3 "sudo -l | grep \"NOPASSWD: #{cmd}\""
        (stdout.read != "")
      end

      # Run a command as sudo.
      #
      # @arg [String] cmd the command to be run
      # @return [Fixnum, IO_Object] the exit status code (_Fixnum_), the standard output (_IO_Object_) and the error output (_IO_Object_)
      def self.run(cmd)
        raise Hermes::Error.new("'sudo' command is not installed or useable by the current user") if !Hermes::Helpers::Sudo.support?
        stdin, stdout, stderr, wait_thr = Open3.popen3 "sudo -n #{cmd}"
        return wait_thr.value.to_i, stdout, stderr
      end
    end
  end
end