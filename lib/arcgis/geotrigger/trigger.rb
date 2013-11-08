module ArcGIS
  module Geotrigger

    class Trigger < Model
      include Taggable

      def default_tag
        'trigger:%s' % triggerId
      end

      def post_update
        raise StateError.new 'not modified' unless @modified

        post_data = @data.dup
        case @session.type
        when :application
          post_data['triggerIds'] = post_data.delete 'triggerId'
        when :device
          post_data.delete 'triggerId'
        end
        post_data.delete 'tags'

        data = post 'trigger/update', post_data
        @data = data['triggers'].select {|t| t['triggerId'] == @data['triggerId']}.first
        @modified = false
        self
      end
      alias_method :save, :post_update

    end

  end
end
