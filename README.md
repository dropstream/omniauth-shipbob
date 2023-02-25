# Omniauth::Shipbob

This is an OmniAuth strategy for authenticating to ShipBob. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'omniauth-shipbob'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install omniauth-shipbob

## Usage

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :shipbob,
         'client_id', 'client_secret',
         :callback_url => 'http://example.test/auth/shipbob/callback',
         :scope => 'scopes-list'
end
```

## Configuring

You can configure integration_name through the authorize_params hash:

```ruby
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :shipbob,
           'client_id', 'client_secret',
           :callback_url => 'http://example.test/auth/shipbob/callback',
           :scope => 'scopes-list',
           :authorize_params => {:integration_name => 'my-application-name' }
end
```

### Configure for Sandbox ENV

Configure these options to use ShipBob's [sandbox](https://developer.shipbob.com/sandbox-simulations) environment.

```ruby
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :shipbob,
           ...,
           api_url: 'https://sandbox-api.shipbob.com/2.0',
           client_options: {
             site: 'https://authstage.shipbob.com'
           },
end
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/omniauth-fdc.
