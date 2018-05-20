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
        let(:config_hash) { { 'style_cop' => { 'definitions' => ['DEBUG', %w[SYMBOL1 SYMBOL2]] } } }
        it { should == [['DEBUG'], %w[SYMBOL1 SYMBOL2]] }
      end
    end

    describe '#parallel' do
      before { stub_const('ENV', 'PRONTO_STYLECOP_PARALLEL' => nil) }
      subject { config.style_cop_parallel }
      context 'parallel is none' do
        it { should == 1 }
      end

      context 'parallel is nil' do
        let(:config_hash) { { 'style_cop' => { 'parallel' => nil } } }
        it { is_expected.to be nil }
      end

      context 'parallel is 4' do
        let(:config_hash) { { 'style_cop' => { 'parallel' => 4 } } }
        it { should == 4 }
      end

      context 'parallel env empty' do
        before { stub_const('ENV', 'PRONTO_STYLECOP_PARALLEL' => '') }
        it { is_expected.to be nil }
      end

      context 'parallel env 1' do
        before { stub_const('ENV', 'PRONTO_STYLECOP_PARALLEL' => '1') }
        it { should == 1 }
      end

      context 'parallel env negative' do
        before { stub_const('ENV', 'PRONTO_STYLECOP_PARALLEL' => '-1') }
        it { should == -1 }
      end
    end
  end
end
