# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "omniauth-shipbob/version"

Gem::Specification.new do |spec|
  spec.name          = "omniauth-shipbob"
  spec.version       = Omniauth::Shipbob::VERSION
  spec.authors       = ["Venkata Kishor"]
  spec.email         = ["kishore.venkat@getdropstream.com"]

  spec.summary       = "OmniAuth strategy for ShipBob"
  spec.description   = "In this gem you will find an OmniAuth ShipBob strategy"
  spec.homepage      = "https://github.com/dropstream/omniauth-shipbob"
  spec.license       = "MIT"

  spec.required_ruby_version = ">= 3.2"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"]      = spec.homepage
  spec.metadata["changelog_uri"]     = "#{spec.homepage}/blob/master/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Ship only the library itself; development scaffolding stays out of the gem.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{\A(?:spec|bin|pkg|\.github)/}) ||
        f.match(%r{\A(?:\.gitignore|\.rspec|\.ruby-version|\.ruby-gemset|Gemfile|Gemfile\.lock|Rakefile)\z})
    end
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "omniauth", "~> 2.0"
  spec.add_dependency "omniauth-oauth2", "~> 1.9"
end
