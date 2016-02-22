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

      def self.client
        @client ||= PuppetX::CenturyLink::Client.new(client_config)
      end

      def client
        self.class.client
      end

      def self.client_config
        config = PuppetX::CenturyLink::Config.new
        {
          username: config.username,
          password: config.password,
        }
      end

      private

      def find_group_by_name(name)
        groups = client.list_groups
        matching_groups = groups.select { |group| group['name'] == name }

        if matching_groups.empty?
          raise Puppet::Error "Group '#{resource[:group]}' not found"
        end
        if matching_groups.size > 1
          raise Puppet::Error, "There are #{matching_groups.size} groups " \
            "matching '#{resource[:group]}'. Consider using group_id"
        end

        matching_groups.first
      end

      def remove_null_values(hash)
        hash.inject({}) do |acc, (key, value)|
          acc[key] = value unless value.nil?
          acc
        end
      end
    end
  end
end
