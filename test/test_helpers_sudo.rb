require 'test/unit'
require 'helpers'
require 'hermes/helpers/sudo'

# Passing these tests require nginx running (with main configuration file at /etc/nginx/nginx.conf) 
# and sudo correctly configured for the current user (run hermes help setup for instructions).
class HermesHelpersSudoTest < Test::Unit::TestCase

  def setup
    Hermes::Helpers::Sudo.class_variable_set(:@@supported, nil) # erase cached supported test for sudo setup
  end

  def test_sudo_support
    assert_block("'Hermes::Helpers::Sudo.support?' must return a boolean") do
      sudo_supported = Hermes::Helpers::Sudo.support?
      (sudo_supported.is_a?(TrueClass) || sudo_supported.is_a?(FalseClass))
    end
  end

  def test_sudo_support_with_sudo_not_installed
    clear_path_env('which') do
      assert !Hermes::Helpers::Sudo.support?
    end
  end

  def test_sudo_cmd_granted
    assert_block("'Hermes::Helpers::Sudo.granted?' must return a boolean") do
      cmd_granted = Hermes::Helpers::Sudo.granted? 'ls'
      (cmd_granted.is_a?(TrueClass) || cmd_granted.is_a?(FalseClass))
    end
  end

  def test_sudo_run
    exit_code, stdout, stderr = Hermes::Helpers::Sudo.run 'ls -la'
    assert_equal Fixnum, exit_code.class, "'Hermes::Helpers::Sudo.run' must return an integer as exit status"
    assert_equal IO, stdout.class , "'Hermes::Helpers::Sudo.run' must return an IO object as stdout"
    assert_equal IO, stderr.class , "'Hermes::Helpers::Sudo.run' must return an IO object as stderr"
  end
end