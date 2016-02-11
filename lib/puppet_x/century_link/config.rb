require 'hocon'
require 'puppet'

module PuppetX
  module CenturyLink
    class Config
      REQUIRED = {
        names: [:username, :password],
        envs: ['CLC_USERNAME', 'CLC_PASSWORD'],
      }

      attr_reader :api_endpoint, :username, :password

      def default_config_file
        Puppet.initialize_settings unless Puppet[:confdir]
        File.join(Puppet[:confdir], 'clc.conf')
      end

      def initialize(config_file = nil)
        settings = process_environment_variables || process_config_file(config_file || default_config_file)
        if settings.nil?
          raise Puppet::Error, 'You must provide credentials in either environment variables or a config file.'
        else
          settings = settings.delete_if { |k, v| v.nil? }
          check_settings(settings)
          @api_endpoint = settings[:api_endpoint]
          @username = settings[:username]
          @password = settings[:password]
        end
      end

      def check_settings(settings)
        missing = REQUIRED[:names] - settings.keys
        unless missing.empty?
          message = 'To use this module you must provide the following settings:'
          missing.each do |var|
            message += " #{var}"
          end
          raise Puppet::Error, message
        end
      end

      def process_config_file(file_path)
        Puppet.debug("Checking for config file at #{file_path}")
        clc_config = read_config_file(file_path)
        if clc_config
          {
            api_endpoint: clc_config['api_endpoint'],
            username: clc_config['username'],
            password: clc_config['password'],
          }
        end
      end

      def read_config_file(file_path)
        if File.file?(file_path)
          begin
            conf = ::Hocon::ConfigFactory.parse_file(file_path)
            conf.root.unwrapped['clc']
          rescue ::Hocon::ConfigError::ConfigParseError => e
            raise Puppet::Error, """Your configuration file at #{file_path} is invalid. The error from the parser is
#{e.message}"""
          end
        end
      end

      def process_environment_variables
        required = REQUIRED[:envs]
        Puppet.debug("Checking for ENV variables: #{required.join(', ')}")
        available = required & ENV.keys
        unless available.empty?
          {
            api_endpoint: ENV['CLC_API_ENDPOINT'],
            username: ENV['CLC_USERNAME'],
            password: ENV['CLC_PASSWORD'],
          }
        end
      end
    end
  end
end
