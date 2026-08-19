# frozen_string_literal: true

require 'omniauth-oauth2'
require 'json'

module OmniAuth
  module Strategies
    class Shipbob < OmniAuth::Strategies::OAuth2
      DEFAULT_API_URL = 'https://api.shipbob.com/1.0'

      option :client_options, {
        :authorize_url => '/connect/integrate',
        :token_url => '/connect/token',
        :site => 'https://auth.shipbob.com',
        # oauth2 2.x defaults to :basic_auth; ShipBob expects the client
        # credentials in the token request body, which was the oauth2 1.x default.
        :auth_scheme => :request_body
      }

      option :authorize_params, { :response_mode => 'form_post' }
      option :api_url, DEFAULT_API_URL

      credentials do
        hash = {"token" => access_token.token}
        hash["refresh_token"] = access_token.refresh_token if access_token.expires? && access_token.refresh_token
        hash["expires_at"] = access_token.expires_at if access_token.expires?
        hash["expires"] = access_token.expires?
        hash['channel_id'] = get_channel_id(access_token)
        hash
      end

      def get_channel_id(token)
        log :info, 'Calling API to get Channel Id.'
        response = token.get(channel_url, :headers => { 'Content-Type' => 'application/json' })
        JSON.parse(response.body).dig(0, "id")
      rescue StandardError => e
        log :error, "Failed to fetch ShipBob Channel Id: #{e.class}: #{e.message}"
        nil
      end

      # The channel endpoint on the configured API host, e.g. ShipBob's sandbox.
      def channel_url
        "#{options.api_url.to_s.chomp('/')}/channel"
      end

      # override callback_url to avoid sending query params along with specified redirect_uri
      def callback_url
        full_host + script_name + callback_path
      end
    end
  end
end
