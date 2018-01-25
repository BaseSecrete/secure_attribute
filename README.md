# Secure Attribute

Secure Attribute is a ruby gem to encrypt attributes of any Ruby object or ActiveRecord model.
While there are already a few encryption gems, Secure Attribute has a different approach:

- No dependencies
- No constraints
- Storage format similar to bcrypt

The goal is not store the password of users when they authenticate to your site. For this purpose it is recommended to use Bcrypt or Scrypt.
However it is a convenient and safe way to store data such as API secrets and tokens or even FTP passwords.
Let's see the importance of encrypting these kind of data.

Let's say your are a market place where you process payments. Each seller gives you the API token of it's payment gateway.
So in your database you have a column `Seller#payment_gateway_secret`.
This token is very sensitive because it can triggers payments and refunds.
If someone got a dump of your database he can move money on the behalf of your customer.
However it this column is encrypted that his much harder for him and you did a good job to protect your users.

That's why you should encrypt any API/Oauth secret/password that your store in your database.

## Examples

First, add `gem "secure_attribute"` to your Gemfile and run `bundle install`.

Then we need to generate an encryption key. A helper method is available which encodes it in base64.
The key is encoded in base 64 because it's more convenient to store it in an environment variable.
For the examples we assume it is stored in environment varaible `SECURE_ATTRIBUTE_KEY`.
Do not loose this key otherwise yon won't be able to decrypt any data.

```ruby
SecureAttribute.export_random_key_base64("AES-256-CBC")
```

There are 2 ways to use it:

- You can call the helper method `attr_secure` which will do everything for you.
It creates the relevant attribute accessors if missing or surrounds them with the encryption mechanism.

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

In addition to the data, Secure Attribute stores the encryption algortihm and the initialization vector into a format inspired by bcrypt:

```
$algorithm$iv$encrypted_data
```

This has 2 benefits. First, you don't need an extra column in your database to store the initialisation vector. Secondly, it gives you more flexibility in the future to switch to another encryption algorithm.

## MIT License

Made by [Base Secrète](https://basesecrete.com/en).

Rails developer? Check out [RoRvsWild](https://www.rorvswild.com), our Ruby on Rails application monitoring tool.
