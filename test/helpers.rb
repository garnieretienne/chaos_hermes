require 'tmpdir'
require 'open3'
require 'hermes/helpers/system'

# Build a PATH env with the given binaries as arguments
#  clear_path_env('sudo', 'which') do
#  ... # PATH contain folder with link to 'sudo' and 'which' commands
#  end
def clear_path_env(*binaries)
  path = Dir.mktmpdir
  binaries.each do |binary|
    binary_path = Hermes::Helpers::System.which binary
    File.symlink(binary_path, "#{path}/#{binary}") if binary_path != ''
  end
  old_path = ENV['PATH']
  ENV['PATH'] = path
  yield
  ENV['PATH'] = old_path
end