require 'forwardable'
require 'httpclient'; class HTTPClient; def inspect; to_s; end; end
require 'json'

require 'pry'

module ArcGIS
  module Geotrigger
    class AGOError < StandardError; end
    class GeotriggerError < StandardError
      attr_accessor :code, :headers, :message, :params
    end
  end
  GT = Geotrigger
end

lib = File.expand_path '../..', __FILE__
$:.push lib unless $:.include? lib
require 'ext/string'

require 'arcgis/geotrigger/ago/session'
require 'arcgis/geotrigger/session'
require 'arcgis/geotrigger/model'

require 'arcgis/geotrigger/application'
require 'arcgis/geotrigger/device'
require 'arcgis/geotrigger/tag'
require 'arcgis/geotrigger/trigger'
