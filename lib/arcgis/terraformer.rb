require 'json'

module ArcGIS
  module Terraformer

    EARTHRADIUS = 6378137
    DEGREES_PER_RADIAN = 57.295779513082320
    RADIANS_PER_DEGREE =  0.017453292519943
    MERCATOR_CRS = {
      type: "link",
      properties: {
        href: "http://spatialreference.org/ref/sr-org/6928/ogcwkt/",
        type: "ogcwkt"
      }
    }
    GEOGRAPHIC_CRS = {
      type: "link",
      properties: {
        href: "http://spatialreference.org/ref/epsg/4326/ogcwkt/",
        type: "ogcwkt"
      }
    }

  end
end

require 'arcgis/terraformer/bounds'
