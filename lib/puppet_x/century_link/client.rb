require 'faraday'
require 'faraday_middleware'
require 'logger'

module PuppetX
  module CenturyLink
    class Client
      class ServerError < StandardError; end
      class InvalidRequest < StandardError; end
      class ResourceNotFound < StandardError; end

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
        server = request(:post, "v2/servers/#{account}", params)
        wait_for(status_id(server))
        request(:get, self_url(server))
      end

      def delete_server(id)
        response = request(:delete, "v2/servers/#{account}/#{id}")
        wait_for(status_id(response))
        true
      end

      def shutdown_server(id)
        operation(:shutDown, id)
        true
      end

      def pause_server(id)
        operation(:pause, id)
        true
      end

      def power_on_server(id)
        operation(:powerOn, id)
        true
      end

      def list_servers(datacenter_id = datacenter_ids)
        Array(datacenter_id).map do |dc_id|
          datacenter = show_datacenter(dc_id)
          group_links = datacenter['links'].select { |l| l['rel'] == 'group' }
          groups = group_links.map do |link|
            group = request(:get, "v2/groups/#{account}/#{link['id']}?serverDetail=detailed")
            flatten_groups(group)
          end.flatten

          groups.map { |group| group['servers'] }.flatten.compact
        end.flatten
      end

      def list_groups
        list_datacenters.map do |dc|
          group_links = dc['links'].select { |link| link['rel'] == 'group' }
          groups = group_links.map do |link|
            group = request(:get, "v2/groups/#{account}/#{link['id']}")
            flatten_groups(group)
          end.flatten
        end.flatten
      end

      def create_group(params)
        request(:post, "v2/groups/#{account}", params)
      end

      def delete_group(id)
        response = request(:delete, "v2/groups/#{account}/#{id}")
        wait_for(response['id'])
        true
      end

      def get_group(id)
        request(:get, "v2/groups/#{account}/#{id}")
      end

      def create_public_ip(server_id, params)
        response = request(:post, "v2/servers/#{account}/#{server_id}/publicIPAddresses", params)
        wait_for(response['id'])
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
        if response.status == 500
          raise ServerError.new(response.body['message'])
        end
        if response.status == 400
          message = if response.body['modelState']
            response.body['modelState'].inspect
          else
            response.body['message']
          end
          raise InvalidRequest.new(message)
        end
        if response.status == 404
          raise ResourceNotFound.new(url)
        end
        response.body
      end

      def operation(operation, id)
        response = request(:post, "v2/operations/#{account}/servers/#{operation}", [id])
        server_response = response.first
        unless server_response['isQueued']
          raise InvalidRequest.new(server_response['errorMessage'])
        end
        wait_for(status_id(server_response))
      end

      def show_operation(id)
        request(:get, "v2/operations/#{account}/status/#{id}")
      end

      def list_datacenters(group_links = true)
        request(:get, "v2/datacenters/#{account}?groupLinks=#{group_links}")
      end

      def show_datacenter(id, group_links = true)
        request(:get, "v2/datacenters/#{account}/#{id}?groupLinks=#{group_links}")
      end

      def datacenter_ids
        list_datacenters.map { |dc| dc['id'] }
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

      def flatten_groups(group)
        child_groups = group.delete('groups')
        return [group] unless child_groups && child_groups.any?
        [group] + child_groups.map { |child| flatten_groups(child) }.flatten
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
