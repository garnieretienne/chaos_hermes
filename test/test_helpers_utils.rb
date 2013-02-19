require 'test/unit'
require 'hermes/helpers/utils'

class HermesHelpersUtilsTest < Test::Unit::TestCase
  
  def test_validate_helper
    assert_nothing_raised Hermes::Error, 'Every params are provided, should not raise an error' do
      Hermes::Helpers::Utils.validate_params :presence, path: '/tmp/hermes/is/fast', foo: 'bar'
    end
    e = assert_raise Hermes::Error, 'Should not raise an error: the :path parameter is not provided' do
      Hermes::Helpers::Utils.validate_params :presence, path: nil, foo: 'bar'
    end
    assert_equal 'No path parameter provided', e.message
    e = assert_raise Hermes::Error, "Should raise an error: the provided doesn't exist" do
      Hermes::Helpers::Utils.validate_params :directory_writable?, path: '/tmp/hermes/is/fast'
    end
    assert_equal "The directory (/tmp/hermes/is/fast) doesn't exist", e.message
  end
end