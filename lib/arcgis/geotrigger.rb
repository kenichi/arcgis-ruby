require 'forwardable'
require 'httpclient'
require 'json'

module ArcGIS

  module Geotrigger

    class AGOError < StandardError; end
    class GeotriggerError < StandardError
      attr_accessor :code, :headers, :message, :params
    end

    class Session

      BASE_URL = 'https://geotrigger.arcgis.com/%s'.freeze

      def initialize opts = {}
        @ago = AGOSession.new opts
        @hc = HTTPClient.new
      end

      def post path, params = {}
        headers = {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{@ago.access_token}"
        }
        r = @hc.post BASE_URL % path, params.to_json, headers
        raise GeotriggerError.new r.body unless r.status == 200
        h = JSON.parse r.body
        if h['error']
          ge = GeotriggerError.new h['error']['message']
          ge.code = h['error']['code']
          ge.headers = h['error']['headers']
          ge.message = h['error']['message']
          ge.params = h['error']['params']
          jj h['error']
          raise ge
        else
          h
        end
      end

    end

    class Model

      extend Forwardable
      def_delegator :@session, :post

      attr_accessor :data

      def initialize opts = {}
        @session = opts[:session] || Session.new(opts)
      end

      def self.from_api data, session
        i = self.new session: session
        i.data = data
        i
      end

      def post_list models, params = {}, default_params = {}
        model = models.sub /s$/, ''
        params = default_params.merge params
        post(model + '/list', params)[models].map do |data|
          Geotrigger.const_get(model.capitalize).from_api data, @session
        end
      end

      def method_missing meth, *args
        meth_s = meth.to_s
        if meth_s =~ /=$/ and args.length == 1
          key = meth_s.sub(/=$/,'').camelcase
          if @data and @data.key? key
            @data[key] = args[0]
          else
            super meth, *args
          end
        else
          key = meth_s.camelcase
          if @data and @data.key? key
            @data[key]
          else
            super meth, *args
          end
        end
      end

    end

    class AGOSession
      extend ::Forwardable
      def_delegators :@impl, :access_token, :ago_data, :device_data, :refresh_token

      AGO_BASE_URL = 'https://www.arcgis.com/sharing/%s'.freeze

      def initialize opts = {}
        @hc = HTTPClient.new
        @impl = case opts[:type] || :application
                when :application
                  Application.new self, opts
                when :device
                  Device.new self, opts
                else
                  raise ArgumentError
                end
      end

      def hc meth, path, params
        r = @hc.__send__ meth, AGO_BASE_URL % path, params.merge(f: 'json')
        raise AGOError.new r.body unless r.status == 200
        h = JSON.parse r.body
        raise AGOError.new r.body if h['error']
        h
      end

      module ExpirySet

        TOKEN_EXPIRY_BUFFER = 10

        def wrap_token_retrieval &block
          yield
          expires_at = Time.now.to_i + @ago_data['expires_in']
          @ago_data[:expires_at] = Time.at expires_at - TOKEN_EXPIRY_BUFFER
          @ago_data
        end

      end

      class Application
        include ExpirySet
        extend ::Forwardable
        def_delegator :@session, :hc

        attr_reader :ago_data

        def initialize session, opts = {}
          @session, @client_id, @client_secret =
            session, opts[:client_id], opts[:client_secret]
        end

        def access_token
          fetch_access_token if @ago_data.nil? or Time.now >= @ago_data[:expires_at]
          @ago_data['access_token']
        end

        private

        def fetch_access_token
          wrap_token_retrieval do
            @ago_data = hc :post, 'oauth2/token',
              client_id: @client_id,
              client_secret: @client_secret,
              grant_type: 'client_credentials'
          end
        end

        def expires_at
        end

      end

      class Device
        include ExpirySet
        extend Forwardable
        def_delegator :@session, :hc

        attr_reader :ago_data, :refresh_token

        def initialize session, opts = {}
          @session, @client_id, @refresh_token =
            session, opts[:client_id], opts[:refresh_token]
        end

        def access_token
          if @ago_data.nil?
            if @refresh_token.nil?
              register
            else
              refresh_access_token
            end
          elsif Time.now >= @ago_data[:expires_at]
            refresh_access_token
          end
          @ago_data['access_token']
        end

        def device_data
          @device_data ||= hc(:get, 'portals/self', token: access_token)['deviceInfo']
        end

        private

        def register
          wrap_token_retrieval do
            data = hc :post, 'oauth2/registerDevice', client_id: @client_id
            @ago_data = {
              'access_token' => data['deviceToken']['access_token'],
              'expires_in' => data['deviceToken']['expires_in']
            }
            @device_data = data['device']
            @refresh_token = data['deviceToken']['refresh_token']
          end
        end

        def refresh_access_token
          wrap_token_retrieval do
            @ago_data = hc :post, 'oauth2/token',
              client_id: @client_id,
              refresh_token: @refresh_token,
              grant_type: 'refresh_token'
          end
        end

      end

    end

  end

  GT = Geotrigger
end

begin
  require 'ext/string'
  require 'arcgis/geotrigger/application'
  require 'arcgis/geotrigger/device'
  require 'arcgis/geotrigger/tag'
  require 'arcgis/geotrigger/trigger'
rescue LoadError
  $:.push File.expand_path '../..', __FILE__
  retry
end
