require 'test/unit'
require 'hermes/route'
require 'tmpdir'
require 'stringio'

# Passing these tests require nginx running (with main configuration file at /etc/nginx/nginx.conf) 
# and sudo correctly configured for the current user (run hermes help setup for instructions).
class HermesRouteTest < Test::Unit::TestCase

  def setup
    @vhost_dir = Dir.mktmpdir
    @params = {
      app_name: 'testing', 
      vhost_dir: @vhost_dir, 
      nginx_conf: '/etc/nginx/nginx.conf',
      domain: 'www.domain.tld',
      upstream: ['120.0.0.1:8080', '120.0.0.1:8181']
    }
  end

  def test_route_required_parameters
    @params.each do |key, value|
      e = assert_raise Hermes::Error, "No raise error for #{key} parameter" do
        Hermes::Route.new @params.select{|x| x != key}
      end
      assert_equal "No #{key} parameter provided", e.message
    end
  end

  def test_route_creation
    assert_nothing_raised Hermes::Error do
      assert_not_nil Hermes::Route.create(@params), "Hermes has not created the temporary VHOST file"
    end
  end

  def test_nginx_route_injection
    assert_nothing_raised Hermes::Error do
      route = Hermes::Route.create(@params)
      route.inject
      assert File.exist?("#{@vhost_dir}/#{@params[:app_name]}"), "NGINX vhost (#{@vhost_dir}/#{@params[:app_name]}) do not exist"
    end
  end

  def test_duplicate_route_creation
    Hermes::Route.create(@params).inject
    e = assert_raise Hermes::Error, 'No raise for duplicate route creation' do
      Hermes::Route.create(@params)
    end
    assert_equal "Route for #{@params[:app_name]} already declared", e.message
  end

  def test_route_creation_with_non_existing_vhost_dir
    params = @params
    params.delete(:vhost_dir)
    params[:vhost_dir] = '/aklnsjhvfjkef'
    e = assert_raise Hermes::Error, 'No raise for unexisting vhost dir' do
      Hermes::Route.new params
    end
    assert_equal "The directory (#{params[:vhost_dir]}) does not exist", e.message
  end

  def test_route_injection_with_non_existing_nginx_conf
    params = @params
    params.delete(:nginx_conf)
    params[:nginx_conf] = '/aklnsjhvfjkef'
    e = assert_raise Hermes::Error, 'No raise for unexisting nginx config file' do
      Hermes::Route.create(params).inject
    end
    assert_equal "The specified file (#{params[:nginx_conf]}) do not exist", e.message
  end
end