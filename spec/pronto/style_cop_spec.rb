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
      subject { style_cop.send(:stylecop_options, definition) }
      before { stub_const('ENV', 'STYLECOP_SETTINGS' => nil) }
      before { stub_const('ENV', 'PRONTO_STYLECOP_SETTINGS' => nil) }

      context 'option definition to flags' do
        let(:definition) { ['DEBUG'] }
        it { should == ["-flags 'DEBUG'"] }
      end

      context 'option array definition to flags' do
        let(:definition) { %w[DEBUG RELEASE] }
        it { should == ["-flags 'DEBUG,RELEASE'"] }
      end

      context 'from config file env variable' do
        before { stub_const('ENV', 'STYLECOP_SETTINGS' => 'Settings.StyleCop') }
        it { should == ["-set 'Settings.StyleCop'"] }
      end

      context 'from config file env variable' do
        before { stub_const('ENV', 'PRONTO_STYLECOP_SETTINGS' => 'Settings.StyleCop') }
        it { should == ["-set 'Settings.StyleCop'"] }
      end

      context 'from config file env variable' do
        before { stub_const('ENV', 'STYLECOP_SETTINGS' => 'Settings.StyleCop') }
        before { stub_const('ENV', 'PRONTO_STYLECOP_SETTINGS' => 'ProntoSettings.StyleCop') }
        it { should == ["-set 'ProntoSettings.StyleCop'"] }
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
