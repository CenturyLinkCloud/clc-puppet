require 'spec_helper'
describe 'clc' do

  context 'with defaults for all parameters' do
    it { should contain_class('clc') }
  end
end
