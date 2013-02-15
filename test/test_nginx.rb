require 'test/unit'
require 'hermes/nginx'

class HermesNginxTest < Test::Unit::TestCase
  
  def setup
    Hermes::Helpers::Sudo.class_variable_set(:@@supported, nil) # erase cached supported test
  end

  def test_dependencies_checking
    clear_path_env('which', 'sudo') do
      assert_raise Hermes::Error, "'nginx' command is not available nor executable by the current user" do 
        Hermes::NGINX.check_dependencies
      end
    end
  end

  def test_check_config_dir_included
    assert_block("'Hermes::NGINX.check_config_dir_included?' must return a boolean") do
      conf_included = Hermes::NGINX.check_config_dir_included?('/tmp', '/etc/nginx/nginx.conf')
      (conf_included.is_a?(TrueClass) || conf_included.is_a?(FalseClass))
    end
  end

  def test_nginx_reload
    assert_block("'Hermes::NGINX.reload' must return a boolean") do
      nginx_is_reloaded = Hermes::NGINX.reload '/etc/nginx/nginx.conf'
      (nginx_is_reloaded.is_a?(TrueClass) || nginx_is_reloaded.is_a?(FalseClass))
    end
  end
end