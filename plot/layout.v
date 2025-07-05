module plot

// Layout
pub struct Layout {
pub mut:
	title         string
	title_x       f64
	autosize      bool
	width         int = 550
	height        int = 550
	xaxis         Axis
	yaxis         Axis
	annotations   []Annotation
	showlegend    bool     @[omitempty]
	plot_bgcolor  string   @[omitempty]
	paper_bgcolor string   @[omitempty]
	polar         Polar    @[omitempty]
	geo           Geo      @[omitempty] // For geographic plots
	mapbox        Mapbox   @[omitempty] // For mapbox plots
}

// Polar layout for radar/polar charts
pub struct Polar {
pub mut:
	radialaxis  RadialAxis  @[omitempty]
	angularaxis AngularAxis @[omitempty]
	sector      []f64       @[omitempty]
	hole        f64         @[omitempty]
	bgcolor     string      @[omitempty]
}

// RadialAxis for polar plots
pub struct RadialAxis {
pub mut:
	visible   bool    @[omitempty]
	range     []f64   @[omitempty]
	tickvals  []f64   @[omitempty]
	ticktext  []string @[omitempty]
	tickangle f64     @[omitempty]
	showgrid  bool    @[omitempty]
	gridcolor string  @[omitempty]
	linecolor string  @[omitempty]
}

// AngularAxis for polar plots
pub struct AngularAxis {
pub mut:
	visible   bool     @[omitempty]
	tickvals  []f64    @[omitempty]
	ticktext  []string @[omitempty]
	direction string   @[omitempty] // 'clockwise' or 'counterclockwise'
	period    f64      @[omitempty]
	rotation  f64      @[omitempty]
	showgrid  bool     @[omitempty]
	gridcolor string   @[omitempty]
	linecolor string   @[omitempty]
}

// ============================================================================
// GEOGRAPHIC LAYOUT STRUCTURES
// ============================================================================

// Geo layout for geographic plots
pub struct Geo {
pub mut:
	scope         string       @[omitempty] // 'world', 'usa', 'europe', 'asia', 'africa', 'north america', 'south america'
	projection    GeoProjection @[omitempty]
	showland      bool         @[omitempty]
	landcolor     string       @[omitempty]
	showocean     bool         @[omitempty]
	oceancolor    string       @[omitempty]
	showlakes     bool         @[omitempty]
	lakecolor     string       @[omitempty]
	showcountries bool         @[omitempty]
	countrycolor  string       @[omitempty]
	showsubunits  bool         @[omitempty]
	subunitcolor  string       @[omitempty]
	resolution    string       @[omitempty] // '110', '50', '10'
	bgcolor       string       @[omitempty]
}

// GeoProjection for geographic projections
pub struct GeoProjection {
pub mut:
	typ      string  @[omitempty] // 'albers usa', 'mercator', 'orthographic', 'natural earth', etc.
	rotation GeoRotation @[omitempty]
	scale    f64     @[omitempty]
	center   GeoCenter @[omitempty]
}

// GeoRotation for geographic rotation
pub struct GeoRotation {
pub mut:
	lon f64 @[omitempty]
	lat f64 @[omitempty]
	roll f64 @[omitempty]
}

// GeoCenter for geographic center
pub struct GeoCenter {
pub mut:
	lon f64 @[omitempty]
	lat f64 @[omitempty]
}

// ============================================================================
// MAPBOX LAYOUT STRUCTURES
// ============================================================================

// Mapbox layout for mapbox plots
pub struct Mapbox {
pub mut:
	style     string       @[omitempty] // 'open-street-map', 'carto-positron', 'carto-darkmatter', 'stamen-terrain', etc.
	center    MapboxCenter @[omitempty]
	zoom      f64          @[omitempty]
	bearing   f64          @[omitempty]
	pitch     f64          @[omitempty]
	accesstoken string     @[omitempty]
}

// MapboxCenter for mapbox center
pub struct MapboxCenter {
pub mut:
	lat f64 @[omitempty]
	lon f64 @[omitempty]
}

// Light for mapbox plots
pub struct Light {
pub mut:
	azimuth   f64     @[omitempty]
	elevation f64     @[omitempty]
	intensity f64     @[omitempty]
	color     []f64    @[omitempty]
}
