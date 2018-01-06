require "base64"
require "openssl"

module SecureAttribute
  def self.included(model)
    model.extend(ClassMethods)
  end

  def self.encipher(algorithm, data, key)
    encrypted, iv = SecureAttribute.encrypt(algorithm, data, key)
    SecureAttribute.pack(algorithm, iv, encrypted)
  end

  def self.decipher(data, key)
    algorithm, iv, data = SecureAttribute.unpack(data)
    SecureAttribute.decrypt(algorithm, data, key, iv)
  end

  def self.encrypt(algorithm, data, key)
    cipher = OpenSSL::Cipher.new(algorithm).encrypt
    cipher.key = key
    iv = cipher.random_iv
    [cipher.update(data) + cipher.final, iv]
  end

  def self.decrypt(algorithm, data, key, iv)
    cipher = OpenSSL::Cipher.new(algorithm).decrypt
    cipher.key, cipher.iv = key, iv
    decrypted = cipher.update(data)
    decrypted << cipher.final
  end

  def self.pack(algorithm, iv, encrypted)
    ["", algorithm, Base64.strict_encode64(iv), Base64.strict_encode64(encrypted)].join("$")
  end

  def self.unpack(string)
    _, algorithm, iv, data = string.split("$")
    [algorithm, Base64.decode64(iv), Base64.decode64(data)]
  end

  def self.export_random_key_base64(algorithm)
    Base64.strict_encode64(OpenSSL::Cipher.new(algorithm).random_key)
  end

  module ClassMethods
    def secure_attribute(name, options = {})
      force_defining_active_record_attribute_accessors
      alias_method attr_reader = "#{name}_without_secure_attribute", "#{name}"
      alias_method attr_writer = "#{name}_without_secure_attribute=", "#{name}="

      define_method("#{name}=") do |data|
        send(attr_writer, SecureAttribute.encipher(options[:algorithm], data, options[:key]))
      end

      define_method(name) do
        SecureAttribute.decipher(send(attr_reader), options[:key])
      end
    end

    def force_defining_active_record_attribute_accessors
      define_attribute_methods if defined?(ActiveRecord::Base) && self < ActiveRecord::Base
    end
  end
end
