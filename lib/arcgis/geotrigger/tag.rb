module ArcGIS
  module Geotrigger

    class Tag < Model

      def triggers params = {}
        post_list 'triggers', params, tag: name
      end

      def devices params = {}
        post_list 'devices', params, tag: name
      end

      def post_update
        raise StateError.new 'not modified' unless @modified
        raise StateError.new 'device access_token prohibited' if @session.device?

        post_data = @data.dup
        post_data['tags'] = post_data.delete 'name'

        data = post 'tag/permissions', post_data
        @data = data['tags'].select {|t| t['name'] == @data['name']}.first
        @modified = false
        self
      end
      alias_method :save, :post_update

    end

  end
end
