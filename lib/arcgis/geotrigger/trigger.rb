module ArcGIS
  module Geotrigger

    class Trigger < Model
      include Taggable

      def initialize opts = {}
        super opts
        if opts[:trigger_id] and @data.nil?
          grok_self_from post('trigger/list', triggerIds: opts[:trigger_id]), opts[:trigger_id]
        end
      end

      def default_tag
        'trigger:%s' % triggerId
      end

      def post_update
        raise StateError.new 'not modified' unless @modified

        post_data = @data.dup
        post_data['triggerIds'] = post_data.delete 'triggerId'
        post_data.delete 'tags'

        grok_self_from post 'trigger/update', post_data
        @modified = false
        self
      end
      alias_method :save, :post_update

      def grok_self_from data, id = nil
        @data = data['triggers'].select {|t| t['triggerId'] == (id || @data['triggerId'])}.first
      end

    end

  end
end
