require 'faraday'
require 'faraday_middleware'
require 'logger'

module PuppetX
  module CenturyLink
    class Client
      attr_reader :account
      attr_reader :connection

      DEFAULT_API_ENDPOINT = 'https://api.ctl.io'
      REQUIRED_PARAMS = [:username, :password]

      def initialize(params = {})
        validate_params(params)

        @connection = Faraday.new(url: params[:endpoint] || DEFAULT_API_ENDPOINT) do |builder|
          builder.request :json
          builder.response :json
          builder.adapter Faraday.default_adapter
        end

        setup_logging(@connection.builder, params[:verbosity]) if params[:verbosity]
        @account = authenticate(params[:username], params[:password])
      end

      def create_server(params)
        server = request(:post, "/v2/servers/#{account}", params)
        wait_for(status_id(server))
        request(:get, self_url(server))
      end

      def delete_server(id)
        body = request(:delete, "v2/servers/#{account}/#{id}")
        wait_for(status_id(body))
        true
      end

      def create_group(params)
        request(:post, "/v2/groups/#{account}", params)
      end

      def delete_group(id)
        body = request(:delete, "/v2/groups/#{account}/#{id}")
        wait_for(body['id'])
        true
      end

      def follow(link)
        request(:get, link['href'])
      end

      def wait_for(operation_id, timeout = 1200)
        expire_at = Time.now + timeout
        loop do
          operation = show_operation(operation_id)
          status = operation['status']
          yield status if block_given?

          case status
          when 'succeeded' then return true
          when 'failed', 'unknown' then raise 'Operation Failed' # reason?
          when 'executing', 'resumed', 'notStarted'
            raise 'Operation takes too much time to complete' if Time.now > expire_at
            next sleep(2)
          else
            raise "Operation status unknown: #{status}"
          end
        end
      end

      private

      def validate_params(params)
        missing = REQUIRED_PARAMS - params.keys
        unless missing.empty?
          message = 'Missing required params:'
          missing.each do |var|
            message += " #{var}"
          end
          raise ArgumentError.new(message)
        end
      end

      def authenticate(username, password)
        response = request(:post, '/v2/authentication/login',
          'username' => username,
          'password' => password
        )

        connection.authorization :Bearer, response.fetch('bearerToken')
        response.fetch('accountAlias')
      end

      def request(method, url, params = nil)
        args = [url]
        args << params if params
        response = connection.send(method, *args)
        response.body
      end

      def show_operation(id)
        connection.get("v2/operations/#{account}/status/#{id}").body
      end

      def status_id(body)
        status_link = status_link(body)
        raise "Status link not found" unless status_link
        status_link['id']
      end

      def status_link(body)
        body['links'].find { |link| link['rel'] == 'status' }
      end

      def self_link(body)
        body['links'].find { |link| link['rel'] == 'self' }
      end

      def self_url(body)
        self_link(body)['href']
      end

      def setup_logging(builder, verbosity)
        case verbosity
        when 1
          builder.response :logger, ::Logger.new(STDOUT)
        when 2
          builder.response :logger, ::Logger.new(STDOUT), :bodies => true
        end
      end
    end
  end
end
