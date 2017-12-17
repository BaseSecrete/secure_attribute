path = File.expand_path("#{File.dirname(__FILE__)}/../lib")
$LOAD_PATH.unshift(path)

require "minitest/autorun"
require "secure_attribute"

class SecureAttributeTest < Minitest::Test
  KEY = Base64.decode64(SecureAttribute.export_random_key_base64("AES-256-CBC"))

  def test_encrypt_decrypt
    data, iv = SecureAttribute.encrypt("AES-256-CBC", "message", KEY)
    assert_equal("message", SecureAttribute.decrypt("AES-256-CBC", data, KEY, iv))
  end

  def test_pack
    assert_equal("$algorithm$aXY=$ZGF0YQ==", SecureAttribute.pack("algorithm", "iv", "data"))
  end

  def test_unpack
    assert_equal(["algorithm", "iv", "data"], SecureAttribute.unpack("$algorithm$aXY=$ZGF0YQ=="))
  end

  class FakeModel
    attr_accessor :secret
    include SecureAttribute
    secure_attribute :secret, algorithm: "AES-256-CBC", key: KEY
  end

  def test_secure_attribute_accessors
    model = FakeModel.new
    model.secret = "test"
    assert_match(/\A\$AES-256-CBC\$/, model.instance_variable_get(:@secret))
    assert_equal("test", model.secret)
  end
end
