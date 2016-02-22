require 'spec_helper'
require 'helpers/unit_spec_helper'

describe Puppet::Type.type(:clc_template) do
  let(:create_params) {
    {
    	name: 'fake'
    }
  }

  it_behaves_like "it has a read-only parameter", :datacenter, :description, :os_type,
  	:storage_size_gb, :capabilities
end
