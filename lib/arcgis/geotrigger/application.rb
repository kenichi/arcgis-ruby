module ArcGIS
  module Geotrigger

    class Application < Model

      def permissions 
        @session.post 'application/permissions'
      end

      def permissions= perms
        @session.post 'application/permissions/update', perms
      end

      def triggers
      end

      def devices params = {}
        @session.post('device/list', params)['devices'].map do |d|
          Device.from_api d, @session
        end
      end

      def tags
      end

    end

  end
end
