module ArcGIS
  module Terraformer
    module Bounds

      def calculate_bounds geojson = nil

        geojson = JSON.parse geojson if String === geojson
        unless Hash === geojson
          raise ArgumentError.new 'must be parsed or parseable geojson'
        end

        case geojson['type']
        when 'Point'
          [ geojson['coordinates'][0], geojson['coordinates'][1],
            geojson['coordinates'][0], geojson['coordinates'][1] ]
        when 'MultiPoint'
          calculate_bounds_from_array geojson['coordinates']
        when 'LineString'
          calculate_bounds_from_array geojson['coordinates']
        when 'MultiLineString'
          calculate_bounds_from_array geojson['coordinates'], 1
        when 'Polygon'
          calculate_bounds_from_array geojson['coordinates'], 1
        when 'MultiPolygon'
          calculate_bounds_from_array geojson['coordinates'], 2
        when 'Feature'
          geojson['geometry'] ? calculate_bounds(geojson['geometry']) : nil
        when 'FeatureCollection'
          calculate_bounds_for_feature_collection geojson
        when 'GeometryCollection'
          calculate_bounds_for_geometry_collection geojson
        else
          raise ArgumentError.new 'unknown type: ' + geojson['type']
        end
      end

      X1, Y1, X2, Y2 = 0, 1, 2, 3

      def calculate_bounds_from_array array, nesting = 0, box = Array.new(4)
        if nesting > 0
          array.reduce box do |b, a|
            calculate_bounds_from_array a, (nesting - 1), b
          end
        else
          array.reduce box do |b, lonlat|
            lon, lat = *lonlat
            set = ->(d, i, t){ b[i] = d if b[i].nil? or d.send(t, b[i]) }
            set[lon, X1, :<]
            set[lon, X2, :>]
            set[lat, Y1, :<]
            set[lat, Y2, :>]
            b
          end
        end
      end

    end

    extend Bounds
  end
end
