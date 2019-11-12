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
      expect(subject.authorize_url).to eq('/connect/authorize')
    end

    it 'should have correct token url' do
      expect(subject.token_url).to eq('/connect/token')
    end
  end
end
