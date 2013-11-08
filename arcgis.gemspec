Gem::Specification.new do |s|
  s.name = "arcgis"
  s.version = "0.0.15"
  # s.rubygems_version = %q{0.0.14}
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Andrew Turner", "Kenichi Nakamura"]
  s.autorequire = %q{arcgis}
  s.date = %q{2013-11-07}
  s.email = %w{aturner@esri.com knakamura@esri.com}
  s.files = ["LICENSE.txt", "README.md"] + Dir['lib/**/*.rb']
  s.require_paths = ["lib"]
  s.summary = %q{A simple wrapper for ArcGIS Online sharing API}

  s.add_dependency 'httpclient'
  s.add_development_dependency "rspec", "~> 2.13"
end
