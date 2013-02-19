require 'erb'

module Hermes

  module Helpers
    
    class Utils

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

    # Build a file using an ERB template.
    # Use ERB's undocumented '-' (explicit trim mode).
    #
    # @param src [String] path to the ERB template file
    # @param dst [String] path to the destination file
    # @return [Boolean] return true if the file has been created, 
    #   false if nothing has been writed in the destination file.
    def self.template(binding, src, dst)
      template = ERB.new IO.read(src), nil, '-'
      (IO.write(dst, template.result(binding)) > 0)
    end
    end
  end
end