module ArcGIS
  module Geotrigger

    class Tag < Model

      def initialize opts = {}
        super opts
        if opts[:name] and @data.nil?
          grok_self_from post('tag/list', tags: opts[:name]), opts[:name]
        end
      end

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
        grok_self_from post 'tag/permissions', post_data
        @modified = false
        self
      end
      alias_method :save, :post_update

      def grok_self_from data, name = nil
        @data = data['tags'].select {|t| t['name'] == (name || @data['name'])}.first
      end

    end

  end
end
