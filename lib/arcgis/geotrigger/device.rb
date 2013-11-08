module ArcGIS
  module Geotrigger

    class Device < Model
      include Taggable

      def default_tag
        'device:%s' % triggerId
      end

      def post_update
        raise StateError.new 'not modified' unless @modified

        post_data = @data.dup
        case @session.type
        when :application
          post_data['deviceIds'] = post_data.delete 'deviceId'
        when :device
          post_data.delete 'deviceId'
        end
        post_data.delete 'tags'
        post_data.delete 'lastSeen'

        data = post 'device/update', post_data
        @data = data['devices'].select {|t| t['deviceId'] == @data['deviceId']}.first
        @modified = false
        self
      end
      alias_method :save, :post_update

    end

  end
end
