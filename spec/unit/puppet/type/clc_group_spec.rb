require 'spec_helper'
require 'helpers/unit_spec_helper'

describe Puppet::Type.type(:clc_group) do
  let(:create_params) {
    {
      :name            => 'name',
      :parent_group_id => 'parent-group',
    }
  }

  [:name, :parent_group_id].each do |field|
    it_behaves_like "it has a non-empty string parameter", field
  end

  it_behaves_like "it has a read-only parameter", :group_id

  it_behaves_like "it has custom fields"
end
