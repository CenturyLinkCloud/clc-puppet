require_relative 'client'

module PuppetX
  module CenturyLink
    class Clc < Puppet::Provider
      def client
        PuppetX::CenturyLink::Client.new(client_config)
      end

      def client_config
        config = PuppetX::CenturyLink::Config.new
        {
          username: config.username,
          password: config.password,
        }
      end
    end
  end
end
