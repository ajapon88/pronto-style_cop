module Pronto
  RSpec.describe StyleCopConfig do
    let(:config) { Config.new(config_hash) }
    let(:config_hash) { {} }
    before { config.extend(StyleCopConfig) }

    describe '#definitions' do
      subject { config.style_cop_definitions }
      context 'definitions is none' do
        it { should == [[]] }
      end

      context 'definitions empty' do
        let(:config_hash) { { 'style_cop' => { 'definitions' => [] } } }
        it { should == [[]] }
      end

      context 'definitions single symbol' do
        let(:config_hash) { { 'style_cop' => { 'definitions' => ['DEBUG'] } } }
        it { should == [['DEBUG']] }
      end

      context 'definitions array symbol' do
        let(:config_hash) { { 'style_cop' => { 'definitions' => ['DEBUG', %w[DEBUG SYMBOL]] } } }
        it { should == [['DEBUG'], %w[DEBUG SYMBOL]] }
      end
    end
  end
end
