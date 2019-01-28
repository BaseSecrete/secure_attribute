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
    def attr_secure(name, options = {})
      ensure_attribute_accessors_are_defined(name)
      alias_method(attr_reader = "#{name}_without_secure_attribute", "#{name}")
      alias_method(attr_writer = "#{name}_without_secure_attribute=", "#{name}=")

      define_method("#{name}=") do |data|
        if data && !data.empty?
          send(attr_writer, SecureAttribute.encipher(options[:algorithm], data, options[:key]))
        else
          send(attr_writer, data)
        end
      end

      define_method(name) do
        if (data = send(attr_reader)) && !data.empty?
          SecureAttribute.decipher(data, options[:key])
        else
          data
        end
      end
    end

    def ensure_attribute_accessors_are_defined(name)
      if defined?(ActiveRecord::Base) && self < ActiveRecord::Base
        define_attribute_method(name)
      else
        attr_writer(name) unless respond_to?("#{name}=")
        attr_reader(name) unless respond_to?(name)
      end
    end
  end
end
