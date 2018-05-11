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
  end
end
