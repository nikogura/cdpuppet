require 'spec_helper'
describe 'cdpuppet::role::jenkins' do
  let(:facts) {
    {
        :osfamily => 'RedHat',
        :operatingsystem => 'RedHat',
        :operatingsystemrelease => "6",
    }
  }

  context 'with defaults for all parameters' do
    it { should contain_class('cdpuppet::role::jenkins') }
  end
end
