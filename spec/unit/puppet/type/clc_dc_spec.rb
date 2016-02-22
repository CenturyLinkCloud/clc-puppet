require 'spec_helper'
require 'helpers/unit_spec_helper'

describe Puppet::Type.type(:clc_dc) do
  let(:create_params) {
    {
      :name => 'name',
    }
  }

  it_behaves_like "it has a read-only parameter", :id
end
