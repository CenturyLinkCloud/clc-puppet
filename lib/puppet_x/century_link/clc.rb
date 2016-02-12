require_relative 'client'
require_relative 'config'

module PuppetX
  module CenturyLink
    class Clc < Puppet::Provider
      def self.read_only(*methods)
        methods.each do |method|
          define_method("#{method}=") do |v|
            fail "#{method} property is read-only once #{resource.type} created"
          end
        end
      end

      def client
        @client ||= PuppetX::CenturyLink::Client.new(client_config)
      end

      def client_config
        config = PuppetX::CenturyLink::Config.new
        {
          username: config.username,
          password: config.password,
        }
      end

      private

      def remove_null_values(hash)
        hash.inject({}) do |acc, (key, value)|
          acc[key] = value unless value.nil?
          acc
        end
      end
    end
  end
end
