module ArcGIS
  module Geotrigger

    class Device < Model

      attr_accessor :id, :tags, :tracking_profile

      def self.from_api hash, session
        i = self.new session: session
        i.id = hash['deviceId']
        i.tags = hash['tags']
        i.tracking_profile = hash['trackingProfile']
        i
      end

    end

  end
end
