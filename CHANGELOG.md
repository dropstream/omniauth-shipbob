# Changelog

All notable changes to this project are documented in this file.

## [0.1.0] - 2026-08-19

### Changed

- **Breaking:** requires `omniauth ~> 2.0` and `omniauth-oauth2 ~> 1.9` (previously
  unpinned, which resolved to `omniauth 1.9` / `oauth2 1.4`). Host applications must
  upgrade to OmniAuth 2.x; Rails apps also need
  [`omniauth-rails_csrf_protection`](https://github.com/cookpad/omniauth-rails_csrf_protection)
  because OmniAuth 2 only accepts `POST` for the request phase.
- Pinned the token endpoint to `auth_scheme: :request_body`. `oauth2 2.0` changed its
  default to `:basic_auth`, which would have moved `client_id`/`client_secret` out of
  the token request body and changed what ShipBob receives.
- Requires Ruby >= 3.2 (the modern `oauth2` dependency chain requires it).
- Development toolchain: Bundler 4.x, `rake ~> 13.0`, `rspec ~> 3.13`.
- Replaced Travis CI with GitHub Actions, testing Ruby 3.2 through 3.4.
- Releases are now cut by pushing a `v*` tag: the `Release` workflow reruns the matrix,
  checks the tag against `version.rb`, publishes to RubyGems.org via trusted publishing
  (OIDC, no stored API key), and opens a GitHub release from this changelog.

### Added

- `LICENSE.txt` (MIT), now declared in the gemspec.
- `channel_url`, which builds the channel endpoint from `api_url` and tolerates a
  trailing slash on the configured value.
- Integration specs covering the request phase, the token exchange, the `redirect_uri`
  override and the auth hash (including `channel_id`), against both the production and
  sandbox hosts.

### Fixed

- Channel lookup failures are now logged instead of being silently discarded.
- `bin/console` required a non-existent `omniauth/fdc` file.
- Development scripts in `bin/` are no longer packaged as gem executables.

## [0.0.3]

- `api_url` is now a strategy option, defaulting to `https://api.shipbob.com/1.0`, so
  the channel lookup can point at ShipBob's sandbox (#10).
- `callback_url` is overridden so query params from a configured `redirect_uri` are not
  sent to ShipBob (#7).

## [0.0.2]

- Initial published strategy.
