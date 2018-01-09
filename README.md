# Secure Attribute

Secure Attribute is a ruby gem to encrypt attributes of any Ruby object or ActiveRecord model.
While there are already a few encryption gems, Secure Attribute has a different approach:

- No dependencies
- No constraints
- Storage format similar to bcrypt

## Examples

First, add `gem "secure_attribute"` to your Gemfile and run `bundle install`.

There are 2 ways to use it:

- You can call the helper method `attr_secure` which will do everything for you.
It creates the relevant attribute accessors if missing or surrounds them with the encryption mechanism.

```ruby
class User < ActiveRecord::Base
  include SecureAttribute
  attr_secure :secret, algorithm: "AES-256-CBC", key: Base64.decode64(ENV["SECURE_ATTRIBUTE_KEY"])
end

user = User.new(secret: "test")
user.attributes[:secret] # => "$AES-256-CBC$c+qXJa1f3dd8y26rjAvGNQ==$fhMvLkC7g+gaw5pxqpkFlQ=="
user.secret # => "test"
```

- If your prefer to control manually the encryption stuff, or if the surrounding attribute accessors mess up with your code, you can do it like this:

```ruby
class User
  def secret=(value)
    @secret = SecureAttribute.encipher("AES-256-CBC", value, ENV["SECURE_ATTRIBUTE_KEY"])
  end

  def secret
    SecureAttribute.decipher(@secret, ENV["SECURE_ATTRIBUTE_KEY"]) if @secret
  end
end
```

## Key generation

A helper method is available to generate a key. It is encoded in base64 to allow you to copy and paste it into an environment variable.

```ruby
SecureAttribute.export_random_key_base64("AES-256-CBC")
```

## Storage format

In addition to the data, Secure Attribute stores the encryption algortihm and the initialization vector into a format inspired by bcrypt:

```
$algorithm$iv$encrypted_data
```

This has 2 benefits. First, you don't need an extra column in your database to store the initialisation vector. Secondly, it gives you more flexibility in the future to switch to another encryption algorithm.

## MIT License

Made by [Base Secrète](https://basesecrete.com/en).

Rails developer? Check out [RoRvsWild](https://www.rorvswild.com), our Ruby on Rails application monitoring tool.
