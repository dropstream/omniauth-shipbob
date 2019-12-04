require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Shipbob < OmniAuth::Strategies::OAuth2
    
      option :client_options, {
        :authorize_url => '/connect/integrate',
        :token_url => '/connect/token',
        :site => 'https://auth.shipbob.com'
      }
      
      #option :provider_ignores_state, true
      
      def callback_phase
        binding.pry
        super
      end
      
    end
  end
end
