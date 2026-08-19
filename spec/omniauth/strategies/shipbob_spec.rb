# frozen_string_literal: true

RSpec.describe OmniAuth::Strategies::Shipbob do
  let(:inner_app) { ->(_env) { [200, {}, ["Hello."]] } }
  let(:strategy_options) { {} }
  let(:strategy) { described_class.new(inner_app, "client_id", "client_secret", **strategy_options) }

  def app
    described_class.new(inner_app, "client_id", "client_secret", **strategy_options)
  end

  describe "#client_options" do
    subject(:client_options) { strategy.options.client_options }

    it "points at the ShipBob auth site" do
      expect(client_options.site).to eq("https://auth.shipbob.com")
    end

    it "has the correct authorize url" do
      expect(client_options.authorize_url).to eq("/connect/integrate")
    end

    it "has the correct token url" do
      expect(client_options.token_url).to eq("/connect/token")
    end

    # oauth2 >= 2.0 defaults to :basic_auth, which would move the client
    # credentials out of the token request body.
    it "sends client credentials in the request body" do
      expect(client_options.auth_scheme).to eq(:request_body)
    end
  end

  describe "#api_url" do
    it "defaults to the production API" do
      expect(strategy.options.api_url).to eq("https://api.shipbob.com/1.0")
    end

    context "when api_url is set" do
      let(:strategy_options) { {api_url: "https://sandbox-api.shipbob.com/2.0"} }

      it "uses the configured value" do
        expect(strategy.options.api_url).to eq("https://sandbox-api.shipbob.com/2.0")
      end
    end
  end

  describe "#channel_url" do
    it "is built from the default api_url" do
      expect(strategy.channel_url).to eq("https://api.shipbob.com/1.0/channel")
    end

    context "when api_url is set" do
      let(:strategy_options) { {api_url: "https://sandbox-api.shipbob.com/2.0"} }

      it "is built from the configured api_url" do
        expect(strategy.channel_url).to eq("https://sandbox-api.shipbob.com/2.0/channel")
      end
    end

    context "when api_url has a trailing slash" do
      let(:strategy_options) { {api_url: "https://sandbox-api.shipbob.com/2.0/"} }

      it "does not double up the separator" do
        expect(strategy.channel_url).to eq("https://sandbox-api.shipbob.com/2.0/channel")
      end
    end
  end

  describe "the request phase" do
    around do |example|
      previous = OmniAuth.config.request_validation_phase
      OmniAuth.config.request_validation_phase = proc {}
      example.run
      OmniAuth.config.request_validation_phase = previous
    end

    it "redirects to ShipBob with response_mode=form_post" do
      post "/auth/shipbob", {}, "rack.session" => {}

      expect(last_response.status).to eq(302)
      location = URI.parse(last_response.headers["Location"])
      expect("#{location.scheme}://#{location.host}#{location.path}")
        .to eq("https://auth.shipbob.com/connect/integrate")
      expect(URI.decode_www_form(location.query).to_h)
        .to include("response_mode" => "form_post", "client_id" => "client_id")
    end

    context "when configured for the sandbox" do
      let(:strategy_options) { {client_options: {site: "https://authstage.shipbob.com"}} }

      it "redirects to the configured auth site" do
        post "/auth/shipbob", {}, "rack.session" => {}

        expect(last_response.headers["Location"])
          .to start_with("https://authstage.shipbob.com/connect/integrate")
      end
    end
  end

  describe "the callback phase" do
    let(:session) { {"omniauth.state" => "abc123"} }
    let(:token_url) { "#{strategy.options.client_options[:site]}/connect/token" }

    before do
      stub_request(:post, token_url).to_return(
        status: 200,
        body: {access_token: "token123", token_type: "Bearer"}.to_json,
        headers: {"Content-Type" => "application/json"}
      )

      stub_request(:get, strategy.channel_url).to_return(
        status: 200,
        body: [{id: 42, name: "Dropstream"}].to_json,
        headers: {"Content-Type" => "application/json"}
      )
    end

    def complete_callback(query = "")
      post "/auth/shipbob/callback#{query}",
           {"code" => "auth_code", "state" => "abc123"},
           "rack.session" => session
    end

    it "exchanges the code for a token with credentials in the body" do
      complete_callback

      expect(WebMock).to have_requested(:post, token_url)
        .with { |req| URI.decode_www_form(req.body).to_h.values_at("client_id", "client_secret") == %w[client_id client_secret] }
    end

    # PR #7: the redirect_uri sent to ShipBob must not carry the callback's query params.
    it "sends a redirect_uri without query params" do
      complete_callback("?utm_source=shipbob")

      expect(WebMock).to have_requested(:post, token_url)
        .with { |req| URI.decode_www_form(req.body).to_h["redirect_uri"] == "http://example.org/auth/shipbob/callback" }
    end

    it "builds an auth hash carrying the token and channel id" do
      complete_callback

      credentials = last_request.env["omniauth.auth"]["credentials"]
      expect(credentials["token"]).to eq("token123")
      expect(credentials["channel_id"]).to eq(42)
      expect(credentials["expires"]).to be(false)
    end

    context "when configured for the sandbox" do
      let(:strategy_options) do
        {
          api_url: "https://sandbox-api.shipbob.com/2.0",
          client_options: {site: "https://authstage.shipbob.com"}
        }
      end

      it "exchanges the token and fetches the channel against the sandbox hosts" do
        complete_callback

        expect(WebMock).to have_requested(:post, "https://authstage.shipbob.com/connect/token")
        expect(WebMock).to have_requested(:get, "https://sandbox-api.shipbob.com/2.0/channel")
        expect(last_request.env["omniauth.auth"]["credentials"]["channel_id"]).to eq(42)
      end
    end
  end

  describe "#get_channel_id" do
    let(:access_token) { OAuth2::AccessToken.new(strategy.client, "token123") }

    it "returns the id of the first channel" do
      stub_request(:get, strategy.channel_url)
        .with(headers: {"Authorization" => "Bearer token123"})
        .to_return(status: 200, body: [{id: 7}].to_json, headers: {"Content-Type" => "application/json"})

      expect(strategy.get_channel_id(access_token)).to eq(7)
    end

    it "returns nil when the channel list is empty" do
      stub_request(:get, strategy.channel_url)
        .to_return(status: 200, body: "[]", headers: {"Content-Type" => "application/json"})

      expect(strategy.get_channel_id(access_token)).to be_nil
    end

    it "returns nil when the API errors" do
      stub_request(:get, strategy.channel_url).to_return(status: 500, body: "boom")

      expect(strategy.get_channel_id(access_token)).to be_nil
    end
  end
end
