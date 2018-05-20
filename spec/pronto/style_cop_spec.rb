module Pronto
  RSpec.describe StyleCop do
    let(:style_cop) { StyleCop.new(patches) }
    let(:patches) { nil }

    describe '#run' do
      subject { style_cop.run }

      context 'patches are nil' do
        it { should == [] }
      end

      context 'no patches' do
        let(:patches) { [] }
        it { should == [] }
      end
    end

    describe '#options' do
      let(:definition) { [] }
      let(:stylecop_settings) { nil }
      subject { style_cop.send(:stylecop_options, definition) }
      before { stub_const('ENV', 'STYLECOP_SETTINGS' => stylecop_settings) }

      context 'option definition to flags' do
        let(:definition) { ['DEBUG'] }
        it { should == ["-flags 'DEBUG'"] }
      end

      context 'option array definition to flags' do
        let(:definition) { %w[DEBUG RELEASE] }
        it { should == ["-flags 'DEBUG,RELEASE'"] }
      end

      context 'from config file env variable' do
        let(:stylecop_settings) { 'Settings.StyleCop' }
        it { should == ["-set '#{stylecop_settings}'"] }
      end
    end
    describe '#parallel' do
      subject { style_cop.send(:parallel) }

      context 'parallel negative' do
        before { stub_const('ENV', 'PRONTO_STYLECOP_PARALLEL' => '-1') }
        it { is_expected.to be nil }
      end
    end
  end
end
