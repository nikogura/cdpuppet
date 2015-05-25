require 'spec_helper'
describe 'puppetjenkins' do

  context 'with defaults for all parameters' do
    it { should contain_class('puppetjenkins') }
  end
end
