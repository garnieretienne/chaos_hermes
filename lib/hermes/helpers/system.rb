module Hermes

  module Helpers

    # This class group helpers for system utilities wrapper.
    class System

      # Locate a command.
      # The path will be found if the file appear in one folder of the PATH environment variable.
      # Use the `which` unix utility.
      #
      # @param [String] binary binary name
      # @return [String] the pathnames of the binary
      def self.which(cmd)
        Open3.popen3("which #{cmd}")[1].read.chomp
      end
    end
  end
end