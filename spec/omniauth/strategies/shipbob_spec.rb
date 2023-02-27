RSpec.describe OmniAuth::Strategies::Shipbob do
  def app
    lambda do |_env|
      [200, {}, ["Hello."]]
    end
  end
  let(:strategy) { Class.new(OmniAuth::Strategies::Shipbob) }

  describe "#client_options" do
    subject { strategy.new(app).options.client_options }

    it 'should have correct authorize url' do
      expect(subject.authorize_url).to eq('/connect/integrate')
    end

    it 'should have correct token url' do
      expect(subject.token_url).to eq('/connect/token')
    end
  end

  describe '#options' do
    subject { strategy.new(app).options }

    it 'should have default api_url' do
      expect(subject.api_url).to eq('https://api.shipbob.com/1.0')
    end

    context 'when api_url is set' do
      let(:staging_api_url) { 'https://example.com/1.0' }

      subject { strategy.new(app, { api_url: staging_api_url }).options }
  
      it 'should have correct api_url' do
        expect(subject.api_url).to eq(staging_api_url)
      end
    end
  end
end
