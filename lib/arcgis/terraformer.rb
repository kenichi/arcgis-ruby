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

module Enumerable

  def each_coordinate opts = {}, &block
    self.iter_coordinate :each, opts, &block
  end

  def map_coordinate opts = {}, &block
    self.iter_coordinate :map, opts, &block
  end
  alias_method :collect_coordinate, :map_coordinate

  def map_coordinate! opts = {}, &block
    self.iter_coordinate :map!, opts, &block
  end
  alias_method :collect_coordinate!, :map_coordinate!

  def iter_coordinate meth, opts = {}, &block
    opts[:recurse] = true if opts[:recurse].nil?
    self.__send__ meth do |pair|
      raise IndexError unless Array === pair
      case pair[0]
      when Numeric
        yield pair
      when Array
        pair.iter_coordinate meth, opts, &block if opts[:recurse]
      else
        raise IndexError.new "#{pair[0]} is not a Numeric or Array type"
      end
    end
  end
  private :iter_coordinate

end

class Float

  def to_deg
    self * ArcGIS::Terraformer::DEGREES_PER_RADIAN
  end

  def to_rad
    self * ArcGIS::Terraformer::RADIANS_PER_DEGREE
  end

end

class Coordinate < Array

  def intialize size_or_ary, obj = nil
  end

end

require 'arcgis/terraformer/bounds'
