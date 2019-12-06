require 'omniauth-oauth2'
require 'json'

module OmniAuth
  module Strategies
    class Shipbob < OmniAuth::Strategies::OAuth2
    
      option :client_options, {
        :authorize_url => '/connect/integrate',
        :token_url => '/connect/token',
        :site => 'https://auth.shipbob.com'
      }
      
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
        response = token.get('https://api.shipbob.com/1.0/channel', :headers => { 'Content-Type' => 'application/json' })
        JSON.parse(response.body).dig(0, "id")
      rescue => e
        nil  
      end
      
    end
  end
end
