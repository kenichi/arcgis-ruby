module ArcGIS
  module Geotrigger

    class Tag < Model

      def triggers params = {}
        post_list 'triggers', params, tag: name
      end

      def devices params = {}
        post_list 'devices', params, tag: name
      end

    end

  end
end
