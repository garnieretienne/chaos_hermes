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
    assert_equal "The directory (#{params[:vhost_dir]}) doesn't exist", e.message
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

  def test_route_upgrade
    Hermes::Route.create(@params).inject
    params = @params
    params[:upstream] = ['127.0.0.1:80']
    assert_nothing_raised Hermes::Error do
      Hermes::Route.update(@params).inject
    end
    assert File.exist?("#{@vhost_dir}/#{@params[:app_name]}"), "NGINX vhost (#{@vhost_dir}/#{@params[:app_name]}) do not exist"
    assert !(IO.read("#{@vhost_dir}/#{@params[:app_name]}") =~ /127.0.0.1:80/).nil?, "The new upstream address cannot be found in the updated vhost"
  end

  def test_updating_an_unexistant_route
    e = assert_raise Hermes::Error, "No error raise on updating an unexisting app route" do
      Hermes::Route.update(@params)
    end
    assert_equal "Route for #{@params[:app_name]} doesn't exist", e.message
  end

  def test_destroying_a_route
    Hermes::Route.create(@params).inject
    assert_nothing_raised Hermes::Error do
      Hermes::Route.destroy @params
    end
  end

  def test_destroying_an_unexisting_route
    e = assert_raise Hermes::Error, "No error message raised trying to delete an unexisting route" do
      Hermes::Route.destroy @params
    end
    assert_equal "Route for '#{@params[:app_name]}' can't be deleted (#{@params[:vhost_dir]}/#{@params[:app_name]} config file doen't exist)", e.message
  end

  def test_routed_apps_list
    assert Hermes::Route.list(vhost_dir: @params[:vhost_dir]).empty?, "Vhost dir should be empty"
    Hermes::Route.create(@params).inject
    assert !Hermes::Route.list(vhost_dir: @params[:vhost_dir]).empty?, "Vhost dir shouldn't be empty"
  end
end