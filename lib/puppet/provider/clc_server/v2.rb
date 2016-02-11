require_relative '../../../puppet_x/century_link/clc'

Puppet::Type.type(:clc_server).provide(:v2, parent: PuppetX::CenturyLink::Clc) do
  def self.instances
    raise NotImplementedError
  end

  def create
    raise NotImplementedError
  end

  def destroy
    raise NotImplementedError
  end
end
