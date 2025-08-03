# Clima API Documentation

## Overview

Clima is a SwiftUI-based educational application that helps students and educators explore and understand climate justice through interactive visualizations. This documentation covers all public APIs, functions, and components available in the codebase.

## Table of Contents

1. [Data Models](#data-models)
2. [Enumerations](#enumerations)
3. [Managers & Helpers](#managers--helpers)
4. [Views & Components](#views--components)
5. [Extensions](#extensions)
6. [Usage Examples](#usage-examples)

---

## Data Models

### Country

The core data model representing a country and its climate-related metrics.

```swift
struct Country: Identifiable, Equatable, Decodable
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | `String` | Unique country identifier (ISO country code) |
| `name` | `String` | Full country name |
| `latitude` | `Double` | Geographic latitude coordinate |
| `longitude` | `Double` | Geographic longitude coordinate |
| `territorialMtCO2` | `Double` | Territorial CO2 emissions in megatonnes |
| `NDGainScore` | `Double` | Notre Dame Global Adaptation Initiative score (0-100) |

#### Core Methods

##### `getRegion() -> Region`
Returns the geographical region for the country based on its ISO code.

**Returns:** `Region` enum value (africa, asia, europe, northAmerica, southAmerica, oceania)

**Example:**
```swift
let country = Country(id: "us", name: "United States", ...)
let region = country.getRegion() // Returns .northAmerica
```

##### `getCoordinate() -> CLLocationCoordinate2D`
Converts the country's latitude and longitude into a CoreLocation coordinate.

**Returns:** `CLLocationCoordinate2D` for use with MapKit

**Example:**
```swift
let coordinate = country.getCoordinate()
// Use with MapKit annotations
```

##### `getMapCameraPosition() -> MapCameraPosition`
Creates a map camera position centered on the country with appropriate zoom level.

**Returns:** `MapCameraPosition` with 3,000km radius view

**Example:**
```swift
@State private var mapPosition = country.getMapCameraPosition()
Map(position: $mapPosition) { ... }
```

#### Climate Justice Score Methods

##### `getClimaJusticeScore(minLog: Double, rangeLog: Double) -> Double`
Calculates the Clima Justice Score - a composite metric that rewards low emissions combined with high vulnerability.

**Parameters:**
- `minLog`: Minimum logarithmic CO2 value for normalization
- `rangeLog`: Range of logarithmic CO2 values for normalization

**Returns:** Climate justice score (0-100)

**Formula:** Harmonic mean of normalized inverse CO2 emissions and inverse ND-GAIN score

**Example:**
```swift
let (minLog, rangeLog) = countries.logCO2Scaling()
let score = country.getClimaJusticeScore(minLog: minLog, rangeLog: rangeLog)
```

##### `getColorForClimaJusticeScore(_ score: Double) -> Color`
Returns a color representation of the climate justice score using a traffic light gradient.

**Parameters:**
- `score`: Climate justice score (0-100)

**Returns:** SwiftUI `Color` (red for low scores, yellow for medium, green for high)

**Example:**
```swift
let score = country.getClimaJusticeScore(minLog: minLog, rangeLog: rangeLog)
let color = country.getColorForClimaJusticeScore(score)
Circle().fill(color)
```

##### `getScaleFactor(for score: Double, minScale: Double = 0.5, maxScale: Double = 3.0) -> Double`
Returns a scale factor for visual representation based on climate justice score.

**Parameters:**
- `score`: Climate justice score (0-100)
- `minScale`: Minimum scale factor (default: 0.5)
- `maxScale`: Maximum scale factor (default: 3.0)

**Returns:** Scale factor inversely proportional to the score

### CountryDataManager

ObservableObject that manages country data loading and provides data access methods.

```swift
final class CountryDataManager: ObservableObject
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `countries` | `@Published [Country]` | Array of all loaded countries |

#### Methods

##### `init()`
Initializes the manager and automatically loads country data from the JSON bundle.

##### `loadData()`
Loads country data from the `clima_countries_data.json` file in the app bundle.

**Example:**
```swift
let manager = CountryDataManager()
// Data is automatically loaded on initialization
```

##### `getCountryClimaJusticeScoreRank(for country: Country) -> Int`
Returns the rank of a country based on its Climate Justice Score.

**Parameters:**
- `country`: The country to rank

**Returns:** Rank position (1-based indexing, 1 = highest score)

**Example:**
```swift
let rank = manager.getCountryClimaJusticeScoreRank(for: country)
print("Country ranks #\(rank) in climate justice")
```

---

## Enumerations

### TabViewItem

Defines the main navigation tabs in the application.

```swift
enum TabViewItem: String, Identifiable, CaseIterable
```

#### Cases

| Case | Raw Value | System Image | Description |
|------|-----------|--------------|-------------|
| `map` | "Map" | "map" | Interactive map view |
| `charts` | "Charts" | "chart.xyaxis.line" | Data visualization charts |
| `compare` | "Compare" | "arrow.left.arrow.right" | Country comparison tool |
| `resources` | "Resources" | "richtext.page" | Educational resources |

#### Properties

##### `id: Self`
Identifiable conformance property.

##### `imageName: String`
Returns the SF Symbol name for the tab icon.

**Example:**
```swift
TabView {
    ForEach(TabViewItem.allCases) { tab in
        Tab(tab.rawValue, systemImage: tab.imageName) {
            // Tab content
        }
    }
}
```

### ChartType

Comprehensive enumeration of all available chart types in the application.

```swift
enum ChartType: String, CaseIterable, Identifiable
```

#### Top 10 Charts

| Case | Description |
|------|-------------|
| `top10CountriesByTerritorialMtCO2` | Countries with highest CO2 emissions |
| `top10CountriesByNDGainScore` | Countries with highest climate resilience |
| `top10CountriesByClimaJusticeScore` | Countries with highest climate justice scores |
| `bottom10CountriesByClimaJusticeScore` | Countries with lowest climate justice scores |

#### Regional Charts

| Case | Description |
|------|-------------|
| `territorialMtCO2ByRegion` | CO2 emissions aggregated by region |
| `ndGainScoreByRegion` | Climate resilience aggregated by region |
| `climaJusticeScoreByRegion` | Climate justice scores aggregated by region |

#### Comparative Charts

| Case | Description |
|------|-------------|
| `territorialMtCO2vsNDGainScore` | Scatter plot of emissions vs resilience |
| `territorialMtCO2vsClimaJusticeScore` | Scatter plot of emissions vs climate justice |
| `ndGainScorevsClimaJusticeScore` | Scatter plot of resilience vs climate justice |

#### Static Properties

##### `top10Charts: [Self]`
Array containing all top 10 ranking chart types.

##### `regionalCharts: [Self]`
Array containing all regional aggregation chart types.

##### `comparativeCharts: [Self]`
Array containing all scatter plot comparison chart types.

#### Instance Properties

##### `imageName: String`
Returns appropriate SF Symbol for the chart type:
- Bar charts: `"chart.bar.yaxis"`
- Pie charts: `"chart.pie.fill"`
- Scatter plots: `"chart.dots.scatter"`

##### `description: String`
Returns detailed educational description of what the chart shows and its significance for climate justice education.

**Example:**
```swift
let chartType = ChartType.top10CountriesByClimaJusticeScore
let description = chartType.description
// Returns comprehensive educational explanation
```

### DataType

Represents the three main data metrics used throughout the application.

```swift
enum DataType: String, Identifiable, CaseIterable
```

#### Cases

| Case | Raw Value | SF Symbol | Color | Description |
|------|-----------|-----------|-------|-------------|
| `climaJusticeScore` | "Clima Justice Score" | "scale.3d" | Orange | Composite climate justice metric |
| `territorialMtCO2` | "Territorial MtCO2" | "carbon.dioxide.cloud.fill" | Yellow | CO2 emissions data |
| `ndGainScore` | "ND-Gain Score" | "shield.lefthalf.filled" | Green | Climate resilience data |

#### Properties

##### `imageName: String`
Returns the SF Symbol name for visual representation.

##### `color: Color`
Returns the associated SwiftUI color for consistent theming.

**Example:**
```swift
ForEach(DataType.allCases) { dataType in
    Label(dataType.rawValue, systemImage: dataType.imageName)
        .foregroundColor(dataType.color)
}
```

### Region

Geographical regions for country categorization.

```swift
enum Region: String, Identifiable, CaseIterable
```

#### Cases

| Case | Raw Value |
|------|-----------|
| `africa` | "Africa" |
| `asia` | "Asia" |
| `europe` | "Europe" |
| `northAmerica` | "North America" |
| `southAmerica` | "South America" |
| `oceania` | "Oceania" |

**Example:**
```swift
let africanCountries = countries.filter { $0.getRegion() == .africa }
```

### CountrySortOption

Sorting options for country lists throughout the application.

```swift
enum CountrySortOption
```

#### Cases

| Case | Description |
|------|-------------|
| `nameAtoZ` | Alphabetical A-Z |
| `nameZtoA` | Alphabetical Z-A |
| `climaJusticeScoreHighToLow` | Climate justice score descending |
| `climaJusticeScoreLowToHigh` | Climate justice score ascending |
| `ndGainScoreHighToLow` | ND-GAIN score descending |
| `ndGainScoreLowToHigh` | ND-GAIN score ascending |
| `territorialMtCO2HighToLow` | CO2 emissions descending |
| `territorialMtCO2LowToHigh` | CO2 emissions ascending |

**Example:**
```swift
let sortedCountries = countries.getFilteredAndSortedCountries(
    countryDataManager: manager,
    searchText: "United",
    sortingOption: .climaJusticeScoreHighToLow
)
```

---

## Managers & Helpers

### OnboardingPresentationManager

ObservableObject that manages the onboarding flow presentation state.

```swift
final class OnboardingPresentationManager: ObservableObject
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `hasSeenOnboarding` | `@AppStorage Bool` | Persisted flag indicating if user has completed onboarding |
| `isShowingOnboarding` | `@Published Bool` | Current onboarding presentation state |

#### Methods

##### `showOnboardingIfNecessary(overriding: Bool = false)`
Shows the onboarding screen if the user hasn't seen it before or if overriding is enabled.

**Parameters:**
- `overriding`: If true, shows onboarding regardless of previous completion

**Example:**
```swift
@StateObject var onboardingManager = OnboardingPresentationManager()

var body: some View {
    ContentView()
        .task { onboardingManager.showOnboardingIfNecessary() }
        .overlay {
            if onboardingManager.isShowingOnboarding {
                OnboardingView()
            }
        }
}
```

##### `dismissOnboarding()`
Dismisses the onboarding screen and marks it as completed for future app launches.

**Example:**
```swift
Button("Complete Onboarding") {
    onboardingManager.dismissOnboarding()
}
```

### DeviceRotationHelper

Provides SwiftUI view modifier for handling device rotation events.

#### DeviceRotationHelperViewModifier

```swift
struct DeviceRotationHelperViewModifier: ViewModifier
```

A view modifier that observes device orientation changes and executes a callback.

**Properties:**
- `action: (UIDeviceOrientation) -> Void` - Callback executed on rotation

#### View Extension

##### `onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View`
Adds rotation detection to any SwiftUI view.

**Parameters:**
- `action`: Closure to execute when device orientation changes

**Returns:** Modified view that responds to orientation changes

**Example:**
```swift
struct ContentView: View {
    @State private var orientation: UIDeviceOrientation = .portrait
    
    var body: some View {
        VStack {
            Text("Current orientation: \(orientation.rawValue)")
        }
        .onRotate { newOrientation in
            orientation = newOrientation
        }
    }
}
```

**Supported Orientations:**
- `UIDeviceOrientation.portrait`
- `UIDeviceOrientation.landscapeLeft`
- `UIDeviceOrientation.landscapeRight`
- `UIDeviceOrientation.portraitUpsideDown`

---

## Views & Components

### ClimaApp

The main application entry point.

```swift
@main
struct ClimaApp: App
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `countryDataManager` | `@StateObject CountryDataManager` | Global data manager |
| `onboardingPresentationManager` | `@StateObject OnboardingPresentationManager` | Onboarding state manager |

#### Usage

The app automatically injects both managers as environment objects for use throughout the view hierarchy.

```swift
// Access in child views
@EnvironmentObject var countryDataManager: CountryDataManager
@EnvironmentObject var onboardingManager: OnboardingPresentationManager
```

### AppTabView

Main navigation interface using SwiftUI's TabView.

```swift
struct AppTabView: View
```

#### Features

- Four main tabs: Map, Charts, Compare, Resources
- Automatic onboarding presentation on first launch
- Environment object dependencies

#### Dependencies

- `OnboardingPresentationManager` (via @EnvironmentObject)

**Example:**
```swift
AppTabView()
    .environmentObject(CountryDataManager())
    .environmentObject(OnboardingPresentationManager())
```

### MapView

Interactive map component displaying countries with climate justice visualization.

```swift
struct MapView: View
```

#### Initializer

```swift
init(showList: Bool = true, showDetails: Bool = true, showAnnotations: Bool = true)
```

**Parameters:**
- `showList`: Whether to display the country list sidebar (default: true)
- `showDetails`: Whether to show detailed country information (default: true)
- `showAnnotations`: Whether to display map annotations (default: true)

#### State Properties

| Property | Type | Description |
|----------|------|-------------|
| `selectedCountry` | `Country?` | Currently selected country |
| `mapCameraPosition` | `MapCameraPosition` | Current map view position |
| `searchText` | `String` | Search filter text |
| `isShowingDetailView` | `Bool` | Detail panel visibility |
| `currentListSortOption` | `CountrySortOption` | List sorting option |

#### Computed Properties

##### `displayedCountriesOnMap: [Country]`
Returns countries to display on the map based on selection state.

##### `displayedCountriesOnList: [Country]`
Returns filtered and sorted countries for the list view.

#### Features

- Interactive map with country annotations
- Color-coded climate justice score visualization
- Searchable country list with multiple sorting options
- Detailed country information panel
- Responsive layout for different screen orientations

**Example:**
```swift
// Basic usage
MapView()

// Custom configuration
MapView(showList: false, showDetails: true, showAnnotations: true)
```

### ChartsView

Data visualization component displaying various climate-related charts.

```swift
struct ChartsView: View
```

#### State Properties

| Property | Type | Description |
|----------|------|-------------|
| `displayedCharts` | `[ChartType]` | Currently selected chart types |
| `isShowingTopDisclaimer` | `Bool` | Data source disclaimer visibility |

#### Features

- Bar charts for top 10 rankings
- Pie charts for regional data aggregation
- Scatter plots for comparative analysis
- Educational descriptions for each chart
- Interactive chart filtering
- Data source disclaimers

#### Chart Categories

1. **Top 10 Charts**: Horizontal bar charts showing country rankings
2. **Regional Charts**: Doughnut charts showing regional aggregations
3. **Comparative Charts**: Scatter plots showing correlations

**Example:**
```swift
ChartsView()
    .environmentObject(countryDataManager)
```

### CompareView

Side-by-side country comparison interface.

```swift
struct CompareView: View
```

#### Initializer

```swift
init(isForOnboarding: Bool = false)
```

**Parameters:**
- `isForOnboarding`: Simplified view for onboarding flow (default: false)

#### State Properties

| Property | Type | Description |
|----------|------|-------------|
| `selectedCountryOnLeft` | `Country?` | Left panel selected country |
| `selectedCountryOnRight` | `Country?` | Right panel selected country |
| `searchTextOnLeft` | `String` | Left panel search text |
| `searchTextOnRight` | `String` | Right panel search text |
| `currentListSortOptionOnLeft` | `CountrySortOption` | Left panel sort option |
| `currentListSortOptionOnRight` | `CountrySortOption` | Right panel sort option |

#### Features

- Dual-panel country selection
- Independent search and sorting for each panel
- Visual comparison of climate metrics
- Map integration for selected countries
- Detailed metric comparison tables

**Example:**
```swift
// Standard comparison view
CompareView()

// Simplified onboarding version
CompareView(isForOnboarding: true)
```

### CountryCard

Reusable country display component.

```swift
struct CountryCard: View
```

#### Initializer

```swift
init(_ country: Country)
```

**Parameters:**
- `country`: The country to display

#### Features

- Country flag display (via remote image)
- Country name with custom typography
- Consistent styling with Material background
- Loading state handling for flag images

**Example:**
```swift
ForEach(countries) { country in
    CountryCard(country)
        .onTapGesture {
            selectedCountry = country
        }
}
```

### ResourcesView Components

#### DataInterpretationView

Educational component explaining data interpretation.

```swift
struct DataInterpretationView: View
```

Provides comprehensive guidance on understanding climate data metrics and their significance.

#### LicensesView

Component displaying open source licenses and attributions.

```swift
struct LicensesView: View
```

Shows legal information and credits for third-party dependencies.

### OnboardingView

Multi-step onboarding flow introducing app features.

```swift
struct OnboardingView: View
```

#### Features

- Step-by-step feature introduction
- Interactive demonstrations
- Progress tracking
- Dismissal handling

**Integration:**
```swift
.overlay {
    if onboardingManager.isShowingOnboarding {
        OnboardingView()
    }
}
```

---

## Extensions

### View Extensions (View+Ext.swift)

SwiftUI View extensions providing common UI utilities and helpers.

#### Layout & Alignment

##### `alignView(to: HorizontalAlignment) -> some View`
Aligns a view horizontally within its container using spacers.

**Parameters:**
- `to`: Horizontal alignment (.leading, .center, .trailing)

**Example:**
```swift
Text("Hello World")
    .alignView(to: .trailing) // Aligns text to the right
```

##### `alignViewVertically(to: VerticalAlignment) -> some View`
Aligns a view vertically within its container using spacers.

**Parameters:**
- `to`: Vertical alignment (.top, .center, .bottom)

**Example:**
```swift
Button("Click Me")
    .alignViewVertically(to: .bottom) // Aligns button to bottom
```

#### Typography

##### `customFont(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> some View`
Applies custom system font with specified parameters.

**Parameters:**
- `size`: Font size in points
- `weight`: Font weight (default: .regular)
- `design`: Font design (default: .default)

**Example:**
```swift
Text("Title")
    .customFont(size: 24, weight: .bold, design: .rounded)
```

#### Keyboard Management

##### `hideKeyboard()`
Dismisses the currently active keyboard.

**Example:**
```swift
VStack {
    TextField("Enter text", text: $text)
    Button("Done") {
        hideKeyboard()
    }
}
```

#### Corner Radius

##### `cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View`
Applies corner radius to specific corners of a view.

**Parameters:**
- `radius`: Corner radius value
- `corners`: Which corners to round (.topLeft, .topRight, .bottomLeft, .bottomRight, .allCorners)

**Example:**
```swift
Rectangle()
    .fill(Color.blue)
    .cornerRadius(15, corners: [.topLeft, .topRight])
```

#### Color Utilities

##### `standardColor(colorScheme: ColorScheme) -> Color`
Returns appropriate color based on color scheme (black for light mode, white for dark mode).

**Parameters:**
- `colorScheme`: Current color scheme

**Example:**
```swift
struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Text("Hello")
            .foregroundColor(standardColor(colorScheme: colorScheme))
    }
}
```

### RoundedCorner Shape

Custom Shape for selective corner rounding.

```swift
struct RoundedCorner: Shape
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `radius` | `CGFloat` | Corner radius (default: .infinity) |
| `corners` | `UIRectCorner` | Which corners to round (default: .allCorners) |

#### Methods

##### `path(in rect: CGRect) -> Path`
Creates the path for the rounded corner shape.

**Example:**
```swift
Rectangle()
    .clipShape(RoundedCorner(radius: 20, corners: [.topLeft, .bottomRight]))
```

### Country Extensions

Extensions to the Country model providing additional functionality.

#### Array Extensions for [Country]

##### `logCO2Scaling() -> (min: Double, range: Double)`
Calculates logarithmic scaling parameters for CO2 emissions normalization.

**Returns:** Tuple containing minimum log value and range for scaling

**Example:**
```swift
let countries: [Country] = // ... load countries
let (minLog, rangeLog) = countries.logCO2Scaling()
// Use for climate justice score calculations
```

##### `getFilteredAndSortedCountries(countryDataManager: CountryDataManager, searchText: String, sortingOption: CountrySortOption) -> [Country]`
Returns filtered and sorted array of countries based on search and sort criteria.

**Parameters:**
- `countryDataManager`: Data manager for accessing country data
- `searchText`: Text to filter country names (supports partial matching)
- `sortingOption`: Sort order from CountrySortOption enum

**Returns:** Filtered and sorted array of countries

**Search Features:**
- Case-insensitive partial matching
- Special character normalization (ü → u)
- Prefix-based matching

**Example:**
```swift
let filteredCountries = countries.getFilteredAndSortedCountries(
    countryDataManager: dataManager,
    searchText: "united",
    sortingOption: .climaJusticeScoreHighToLow
)
```

### Device Rotation Extension

Extension for handling device orientation changes.

#### View Extension

##### `onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View`
Adds device rotation monitoring to any SwiftUI view.

**Parameters:**
- `action`: Closure executed when device orientation changes

**Example:**
```swift
struct RotationAwareView: View {
    @State private var isLandscape = false
    
    var body: some View {
        VStack {
            if isLandscape {
                HStack { /* Landscape layout */ }
            } else {
                VStack { /* Portrait layout */ }
            }
        }
        .onRotate { orientation in
            isLandscape = orientation.isLandscape
        }
    }
}
```

---

## Usage Examples

### Basic App Setup

```swift
import SwiftUI

@main
struct ClimaApp: App {
    @StateObject var countryDataManager = CountryDataManager()
    @StateObject var onboardingPresentationManager = OnboardingPresentationManager()
    
    var body: some Scene {
        WindowGroup {
            AppTabView()
                .environmentObject(countryDataManager)
                .environmentObject(onboardingPresentationManager)
        }
    }
}
```

### Creating a Custom Climate Data View

```swift
import SwiftUI

struct CustomClimateView: View {
    @EnvironmentObject var countryDataManager: CountryDataManager
    @State private var selectedRegion: Region = .africa
    @State private var sortOption: CountrySortOption = .climaJusticeScoreHighToLow
    
    private var filteredCountries: [Country] {
        countryDataManager.countries
            .filter { $0.getRegion() == selectedRegion }
            .getFilteredAndSortedCountries(
                countryDataManager: countryDataManager,
                searchText: "",
                sortingOption: sortOption
            )
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Region Picker
                Picker("Region", selection: $selectedRegion) {
                    ForEach(Region.allCases) { region in
                        Text(region.rawValue).tag(region)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Country List
                List(filteredCountries) { country in
                    CustomCountryRow(country: country)
                }
            }
            .navigationTitle("Climate Data")
        }
    }
}

struct CustomCountryRow: View {
    let country: Country
    @EnvironmentObject var countryDataManager: CountryDataManager
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(country.name)
                    .customFont(size: 16, weight: .medium)
                
                Text("CO₂: \(country.territorialMtCO2, specifier: "%.1f") Mt")
                    .customFont(size: 14, weight: .regular)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Climate Justice Score Indicator
            let (minLog, rangeLog) = countryDataManager.countries.logCO2Scaling()
            let score = country.getClimaJusticeScore(minLog: minLog, rangeLog: rangeLog)
            
            VStack {
                Circle()
                    .fill(country.getColorForClimaJusticeScore(score))
                    .frame(width: 20, height: 20)
                
                Text("\(score, specifier: "%.0f")")
                    .customFont(size: 12, weight: .bold)
            }
        }
        .padding(.vertical, 4)
    }
}
```

### Building a Custom Map Integration

```swift
import SwiftUI
import MapKit

struct CustomMapView: View {
    @EnvironmentObject var countryDataManager: CountryDataManager
    @State private var selectedCountry: Country?
    @State private var mapPosition: MapCameraPosition = .automatic
    
    var body: some View {
        ZStack {
            Map(position: $mapPosition) {
                ForEach(countryDataManager.countries) { country in
                    let (minLog, rangeLog) = countryDataManager.countries.logCO2Scaling()
                    let score = country.getClimaJusticeScore(minLog: minLog, rangeLog: rangeLog)
                    let scaleFactor = country.getScaleFactor(for: score, minScale: 0.3, maxScale: 2.0)
                    
                    Annotation(country.name, coordinate: country.getCoordinate()) {
                        Circle()
                            .fill(country.getColorForClimaJusticeScore(score))
                            .frame(width: 20 * scaleFactor, height: 20 * scaleFactor)
                            .onTapGesture {
                                selectedCountry = country
                                mapPosition = country.getMapCameraPosition()
                            }
                    }
                }
            }
            .mapStyle(.standard)
            
            // Country Detail Overlay
            if let selectedCountry = selectedCountry {
                VStack {
                    Spacer()
                    CountryDetailCard(country: selectedCountry)
                        .padding()
                }
            }
        }
    }
}

struct CountryDetailCard: View {
    let country: Country
    @EnvironmentObject var countryDataManager: CountryDataManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(country.name)
                    .customFont(size: 18, weight: .bold)
                Spacer()
                Text(country.getRegion().rawValue)
                    .customFont(size: 14, weight: .medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8, corners: .allCorners)
            }
            
            let (minLog, rangeLog) = countryDataManager.countries.logCO2Scaling()
            let climateScore = country.getClimaJusticeScore(minLog: minLog, rangeLog: rangeLog)
            let rank = countryDataManager.getCountryClimaJusticeScoreRank(for: country)
            
            VStack(alignment: .leading, spacing: 8) {
                DataMetricRow(
                    title: "Climate Justice Score",
                    value: "\(climateScore, specifier: "%.1f")",
                    subtitle: "Rank: #\(rank)",
                    dataType: .climaJusticeScore
                )
                
                DataMetricRow(
                    title: "Territorial CO₂ Emissions",
                    value: "\(country.territorialMtCO2, specifier: "%.1f") Mt",
                    subtitle: "Megatonnes per year",
                    dataType: .territorialMtCO2
                )
                
                DataMetricRow(
                    title: "ND-GAIN Score",
                    value: "\(country.NDGainScore, specifier: "%.1f")",
                    subtitle: "Climate readiness (0-100)",
                    dataType: .ndGainScore
                )
            }
        }
        .padding()
        .background(Material.thick)
        .cornerRadius(16, corners: .allCorners)
    }
}

struct DataMetricRow: View {
    let title: String
    let value: String
    let subtitle: String
    let dataType: DataType
    
    var body: some View {
        HStack {
            Image(systemName: dataType.imageName)
                .foregroundColor(dataType.color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .customFont(size: 14, weight: .medium)
                Text(subtitle)
                    .customFont(size: 12, weight: .regular)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(value)
                .customFont(size: 16, weight: .bold)
                .foregroundColor(dataType.color)
        }
    }
}
```

### Creating a Custom Chart Component

```swift
import SwiftUI
import Charts

struct CustomClimateChart: View {
    let countries: [Country]
    let chartType: ChartType
    @EnvironmentObject var countryDataManager: CountryDataManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Chart Header
            HStack {
                Image(systemName: chartType.imageName)
                    .foregroundColor(.blue)
                Text(chartType.rawValue)
                    .customFont(size: 18, weight: .bold)
                Spacer()
            }
            .padding(.horizontal)
            
            // Chart Content
            switch chartType {
            case .top10CountriesByClimaJusticeScore:
                climateJusticeBarChart
            case .territorialMtCO2ByRegion:
                regionalPieChart
            default:
                Text("Chart type not implemented in this example")
                    .foregroundColor(.secondary)
            }
            
            // Description
            Text(chartType.description)
                .customFont(size: 12, weight: .regular)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12, corners: .allCorners)
        .shadow(radius: 2)
    }
    
    private var climateJusticeBarChart: some View {
        let (minLog, rangeLog) = countries.logCO2Scaling()
        let topCountries = countries
            .sorted { $0.getClimaJusticeScore(minLog: minLog, rangeLog: rangeLog) > $1.getClimaJusticeScore(minLog: minLog, rangeLog: rangeLog) }
            .prefix(10)
        
        return Chart(Array(topCountries)) { country in
            BarMark(
                x: .value("Score", country.getClimaJusticeScore(minLog: minLog, rangeLog: rangeLog)),
                y: .value("Country", country.name)
            )
            .foregroundStyle(country.getColorForClimaJusticeScore(
                country.getClimaJusticeScore(minLog: minLog, rangeLog: rangeLog)
            ))
        }
        .frame(height: 300)
        .padding(.horizontal)
    }
    
    private var regionalPieChart: some View {
        let regionalData = Dictionary(grouping: countries, by: { $0.getRegion() })
            .mapValues { $0.reduce(0) { $0 + $1.territorialMtCO2 } }
        
        return Chart(regionalData.sorted(by: { $0.value > $1.value }), id: \.key) { region, emissions in
            SectorMark(
                angle: .value("Emissions", emissions),
                innerRadius: .ratio(0.5),
                angularInset: 2
            )
            .foregroundStyle(by: .value("Region", region.rawValue))
        }
        .frame(height: 300)
        .padding(.horizontal)
    }
}
```

### Implementing Search and Filter Functionality

```swift
struct SearchableCountryList: View {
    @EnvironmentObject var countryDataManager: CountryDataManager
    @State private var searchText = ""
    @State private var selectedRegions: Set<Region> = Set(Region.allCases)
    @State private var sortOption: CountrySortOption = .nameAtoZ
    @State private var showingFilters = false
    
    private var filteredCountries: [Country] {
        countryDataManager.countries
            .filter { selectedRegions.contains($0.getRegion()) }
            .getFilteredAndSortedCountries(
                countryDataManager: countryDataManager,
                searchText: searchText,
                sortingOption: sortOption
            )
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search and Filter Controls
                HStack {
                    TextField("Search countries...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Filter") {
                        showingFilters.toggle()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8, corners: .allCorners)
                }
                .padding()
                
                // Filter Panel
                if showingFilters {
                    FilterPanel(
                        selectedRegions: $selectedRegions,
                        sortOption: $sortOption
                    )
                    .transition(.slide)
                }
                
                // Results List
                List(filteredCountries) { country in
                    CountryCard(country)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        .listRowBackground(Color.clear)
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Countries (\(filteredCountries.count))")
            .animation(.easeInOut, value: showingFilters)
        }
    }
}

struct FilterPanel: View {
    @Binding var selectedRegions: Set<Region>
    @Binding var sortOption: CountrySortOption
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Regions")
                .customFont(size: 16, weight: .semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                ForEach(Region.allCases) { region in
                    RegionToggle(
                        region: region,
                        isSelected: selectedRegions.contains(region)
                    ) { isSelected in
                        if isSelected {
                            selectedRegions.insert(region)
                        } else {
                            selectedRegions.remove(region)
                        }
                    }
                }
            }
            
            Text("Sort By")
                .customFont(size: 16, weight: .semibold)
                .padding(.top)
            
            // Simplified sort options for example
            VStack(alignment: .leading, spacing: 8) {
                SortOptionRow(
                    title: "Name (A-Z)",
                    option: .nameAtoZ,
                    selectedOption: $sortOption
                )
                SortOptionRow(
                    title: "Climate Justice Score",
                    option: .climaJusticeScoreHighToLow,
                    selectedOption: $sortOption
                )
                SortOptionRow(
                    title: "CO₂ Emissions",
                    option: .territorialMtCO2HighToLow,
                    selectedOption: $sortOption
                )
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12, corners: .allCorners)
        .padding(.horizontal)
    }
}

struct RegionToggle: View {
    let region: Region
    let isSelected: Bool
    let onToggle: (Bool) -> Void
    
    var body: some View {
        Button(action: { onToggle(!isSelected) }) {
            Text(region.rawValue)
                .customFont(size: 12, weight: .medium)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.3))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(6, corners: .allCorners)
        }
    }
}

struct SortOptionRow: View {
    let title: String
    let option: CountrySortOption
    @Binding var selectedOption: CountrySortOption
    
    var body: some View {
        Button(action: { selectedOption = option }) {
            HStack {
                Text(title)
                    .customFont(size: 14, weight: .regular)
                    .foregroundColor(.primary)
                Spacer()
                if selectedOption == option {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}
```

### Integration Best Practices

#### 1. Environment Object Setup
Always provide required environment objects at the app level:

```swift
WindowGroup {
    AppTabView()
        .environmentObject(CountryDataManager())
        .environmentObject(OnboardingPresentationManager())
}
```

#### 2. Data Loading and Error Handling
Implement proper loading states and error handling:

```swift
struct DataAwareView: View {
    @EnvironmentObject var countryDataManager: CountryDataManager
    
    var body: some View {
        Group {
            if countryDataManager.countries.isEmpty {
                ProgressView("Loading climate data...")
            } else {
                ContentView()
            }
        }
        .onAppear {
            if countryDataManager.countries.isEmpty {
                countryDataManager.loadData()
            }
        }
    }
}
```

#### 3. Performance Optimization
Use computed properties for expensive calculations:

```swift
struct OptimizedCountryList: View {
    @EnvironmentObject var countryDataManager: CountryDataManager
    
    // Cache expensive calculations
    private var scalingParameters: (min: Double, range: Double) {
        countryDataManager.countries.logCO2Scaling()
    }
    
    var body: some View {
        List(countryDataManager.countries) { country in
            let score = country.getClimaJusticeScore(
                minLog: scalingParameters.min,
                rangeLog: scalingParameters.range
            )
            CountryRow(country: country, score: score)
        }
    }
}
```

#### 4. Accessibility Support
Add accessibility features to your views:

```swift
CountryCard(country)
    .accessibilityLabel("\(country.name), Climate justice score: \(score)")
    .accessibilityHint("Tap to view detailed climate information")
```

This comprehensive documentation covers all public APIs, components, and usage patterns in the Clima application. Use these examples as starting points for building custom climate data visualizations and educational tools.