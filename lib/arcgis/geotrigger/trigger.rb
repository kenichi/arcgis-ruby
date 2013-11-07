module ArcGIS
  module Geotrigger

    class Trigger < Model

      def tags params = {}
        post_list 'tags', params, tags: @data['tags']
      end

    end

  end
end
