require 'spec_helper'
describe 'puppetjenkins::role::default' do
  let(:facts) {
    {
        :osfamily => 'RedHat',
        :operatingsystem => 'RedHat',
        :operatingsystemrelease => "6",
    }
  }

  context 'with defaults for all parameters' do
    it { should contain_class('puppetjenkins::role::default') }
  end
end
