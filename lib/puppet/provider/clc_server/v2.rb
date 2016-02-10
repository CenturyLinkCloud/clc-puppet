Puppet::Type.type(:clc_server).provide(:v2) do
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
