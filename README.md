# Omniauth::Shipbob

This is an OmniAuth strategy for authenticating to ShipBob.

Requires Ruby >= 3.2, OmniAuth 2.x and `omniauth-oauth2` 1.9.x.

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

OmniAuth 2 only accepts `POST` for the request phase. In a Rails app, add
[`omniauth-rails_csrf_protection`](https://github.com/cookpad/omniauth-rails_csrf_protection)
to your Gemfile and link to the provider with `button_to` or `link_to ..., method: :post`:

```ruby
gem 'omniauth-rails_csrf_protection'
```

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

### Configure the API endpoint

`api_url` sets the host the strategy calls to look up the channel id that lands in
`credentials['channel_id']`. It defaults to `https://api.shipbob.com/1.0`.

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

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Releasing

Releases are cut by pushing a tag; GitHub Actions builds and publishes the gem to
[rubygems.org](https://rubygems.org) via
[RubyGems trusted publishing](https://guides.rubygems.org/trusted-publishing/), so no API
key is stored in the repo and the gemspec can keep `rubygems_mfa_required`.

1. Bump `VERSION` in `lib/omniauth-shipbob/version.rb` and add a `CHANGELOG.md` section
   for it (the release notes are taken from that section).
2. Commit both on `master`.
3. Tag and push:

   ```sh
   git tag -a v0.1.0 -m "v0.1.0"
   git push origin master --tags
   ```

The `Release` workflow then runs the full test matrix, refuses to continue if the tag and
`version.rb` disagree, pushes the gem, and opens a GitHub release.

### One-time RubyGems setup

Before the first automated release, register this repo as a trusted publisher: on
rubygems.org open the gem → **Trusted publishers** → **Create**, with owner
`dropstream`, repository `omniauth-shipbob`, workflow `release.yml`, and environment
`release`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dropstream/omniauth-shipbob.

## License

Available as open source under the terms of the [MIT License](LICENSE.txt).
