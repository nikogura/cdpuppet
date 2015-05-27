require 'spec_helper'
describe 'cdpuppet' do

  context 'with defaults for all parameters' do
    it { should contain_class('cdpuppet') }
  end
end
