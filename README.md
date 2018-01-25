# Secure Attribute

*Secure Attribute* is a ruby gem to encrypt attributes of any Ruby object or ActiveRecord model. It is made to protect sensitive data, such as API secrets, OAuth tokens or even FTP passwords.

While there are already a few encryption gems out there, *Secure Attribute* has no dependencies and no code constraints.

## Installation

Add `gem "secure_attribute"` to your Gemfile and run `bundle install`.

Then, generate an encryption key:

```ruby
SecureAttribute.export_random_key_base64("AES-256-CBC")
```

The key is encoded in base 64 to make it more convenient to store it in an environment variable.
**Make sure you do not lose your encryption key or you won't be able to decrypt any data.**

## Usage

*For the examples bellow we assume the key is stored in the environment variable `SECURE_ATTRIBUTE_KEY`.*

There are 2 ways to use it:

- You can call the helper method `attr_secure` which creates the relevant attribute accessors if missing, or surrounds them with the encryption mechanism.

```ruby
class User < ActiveRecord::Base
  include SecureAttribute
  attr_secure :oauth_secret, algorithm: "AES-256-CBC", key: Base64.decode64(ENV["SECURE_ATTRIBUTE_KEY"])
end

user = User.new(oauth_secret: "test")
user.attributes[:oauth_secret] # => "$AES-256-CBC$c+qXJa1f3dd8y26rjAvGNQ==$fhMvLkC7g+gaw5pxqpkFlQ=="
user.oauth_secret # => "test"
```

- If your prefer to control manually the encryption stuff, or if the surrounding attribute accessors mess up with your code, you can do it like this:

```ruby
class User
  def oauth_secret=(value)
    @oauth_secret = value ? SecureAttribute.encipher("AES-256-CBC", value, ENV["SECURE_ATTRIBUTE_KEY"]) : nil
  end

  def oauth_secret
    SecureAttribute.decipher(@oauth_secret, ENV["SECURE_ATTRIBUTE_KEY"]) if @oauth_secret
  end
end
```

## Storage format

In addition to the data, *Secure Attribute* stores the encryption algorithm and the initialisation vector into a format inspired by Bcrypt:

```
$algorithm$iv$encrypted_data
```

This has 2 benefits:
- You don't need an extra column in your database to store the initialisation vector.
- It gives you more flexibility in the future to switch to another encryption algorithm.

## MIT License

Made by [Base Secrète](https://basesecrete.com/en).

Rails developer? Check out [RoRvsWild](https://www.rorvswild.com), our Ruby on Rails application monitoring tool.
