require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Shipbob < OmniAuth::Strategies::OAuth2
    
      option :client_options, {
        :authorize_url => '/connect/authorize',
        :token_url => '/connect/token',
        :site => 'https://auth.shipbob.com'
      }
      
    end
  end
end
