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
             :callback_url => "#{Rails.env.production? ? 'https://app.getdropstream.com' : 'http://app.getdropstream.test'}/auth/shipbob/callback",
             :scope => 'orders_write products_read fulfillments_read inventory_read channels_read offline_access',
             :authorize_params => {:integration_name => 'DropStream', :response_mode => 'form_post' }, 
             :setup => lambda { |env| params = Rack::Utils.parse_query(env['QUERY_STRING'])
                                       env['omniauth.strategy'].options[:client_options][:site] = "https://auth.shipbob.com" }
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/omniauth-fdc.
