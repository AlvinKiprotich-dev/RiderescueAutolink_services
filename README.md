#  RideRescue Services

A comprehensive mobile application for roadside assistance service providers, built with Flutter. This app enables service providers to manage their services, handle bookings, and provide real-time assistance to drivers in need.

## 📱 App Overview

RideRescue Services is the companion app for service providers in the RideRescue ecosystem. It allows mechanics, towing services, fuel providers, and other roadside assistance professionals to:

- **Manage Services**: List and organize different types of roadside assistance services
- **Handle Bookings**: Receive and manage service requests from drivers
- **Real-time Communication**: Stay connected with drivers through push notifications
- **Location Services**: Provide location-based assistance using Google Maps
- **Profile Management**: Maintain professional profiles and service details

##  Key Features

###  Service Management
- **Service Listing**: Display all available services with detailed information
- **Service Categories**: Organized by type (Mechanic, Towing, Fuel, Battery, Tire, etc.)
- **Service Details**: Comprehensive service information including pricing, availability, and ratings
- **Service Images**: Visual representation of services with custom icons

###  Booking System
- **Booking Requests**: Receive and review service requests from drivers
- **Booking Details**: View comprehensive booking information including location, vehicle details, and service requirements
- **Status Tracking**: Monitor booking status from request to completion
- **Real-time Updates**: Get instant notifications for new bookings and status changes

###  Location & Navigation
- **Google Maps Integration**: Full mapping capabilities for location-based services
- **GPS Tracking**: Real-time location services for accurate service delivery
- **Geocoding**: Convert addresses to coordinates for precise navigation
- **Location-based Services**: Find nearby service requests and optimize routes

###  Push Notifications
- **OneSignal Integration**: Reliable push notification system
- **Real-time Alerts**: Instant notifications for new bookings and updates
- **Background Processing**: Handle notifications even when app is not active
- **Custom Notifications**: Tailored alerts for different types of service requests

###  User Management
- **Authentication**: Secure login with Google Sign-In
- **Profile Management**: Edit and maintain service provider profiles
- **Settings**: Customize app preferences and notification settings
- **Activity History**: Track past services and bookings

###  Modern UI/UX
- **Material Design**: Clean, modern interface following Material Design principles
- **Dark/Light Theme**: Support for both light and dark themes
- **Responsive Design**: Optimized for various screen sizes
- **Smooth Animations**: Fluid transitions and interactions

##  Technical Stack

### Frontend
- **Flutter**: Cross-platform mobile development framework
- **Dart**: Programming language for Flutter development
- **Riverpod**: State management solution
- **Go Router**: Navigation and routing

### Backend Integration
- **RESTful API**: Communication with backend services
- **HTTP Client**: Network requests and data handling
- **JSON Parsing**: Data serialization and deserialization

### Services & Libraries
- **Google Maps Flutter**: Mapping and location services
- **OneSignal Flutter**: Push notification system
- **Google Sign-In**: Authentication service
- **Geolocator**: Location services and GPS
- **Geocoding**: Address-to-coordinate conversion
- **Image Picker**: Photo and image handling
- **Shared Preferences**: Local data storage
- **URL Launcher**: External link handling

### Development Tools
- **Flutter Lints**: Code quality and style enforcement
- **Flutter Test**: Unit and widget testing
- **Analysis Options**: Custom linting rules

##  App Structure

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # Main app configuration
├── router.dart               # Navigation routes
├── constants/                # App constants and configurations
├── models/                   # Data models
├── providers/                # State management providers
├── services/                 # Business logic and API services
├── screens/                  # UI screens
│   ├── auth/                # Authentication screens
│   ├── home/                # Main app screens
│   │   ├── tabs/           # Bottom navigation tabs
│   │   └── service-form/   # Service management forms
│   ├── booking/             # Booking management
│   ├── pairing/             # Service pairing
│   └── settings/            # App settings
├── theme/                    # App theming and styling
├── utils/                    # Utility functions
├── widgets/                  # Reusable UI components
└── plugins/                  # Custom plugins and utilities
    ├── providers/           # Network and app providers
    ├── theme/               # Theme configurations
    └── utils/               # Background services and utilities
```

##  Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Android SDK (for Android builds)
- Xcode (for iOS builds, macOS only)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd riderescue_services
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment**
   - Set up API endpoints in `lib/constants/api_endpoints.dart`
   - Configure OneSignal in `lib/plugins/utils/onesignal_service.dart`
   - Set up Google Maps API key

4. **Run the app**
   ```bash
   flutter run
   ```

##  Building for Production

### Android App Bundle (.aab)
```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build AAB
flutter build appbundle --release
```

The AAB file will be generated at:
```
build/app/outputs/bundle/release/app-release.aab
```

### iOS Archive
```bash
# Build for iOS
flutter build ios --release
```

##  Configuration

### API Configuration
Update the API endpoints in `lib/constants/api_endpoints.dart`:
```dart
class ApiEndpoints {
  static const String baseUrl = 'https://your-api-domain.com';
  static const String services = '/api/services';
  static const String bookings = '/api/bookings';
  // ... other endpoints
}
```

### OneSignal Setup
Configure OneSignal in `lib/plugins/utils/onesignal_service.dart`:
```dart
class OneSignalService {
  static const String appId = 'YOUR_ONESIGNAL_APP_ID';
  // ... configuration
}
```

### Google Maps
Add your Google Maps API key in `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY" />
```

##  Theming

The app uses a custom color scheme with orange (#EC8027) and dark gray (#282828) as primary colors. Theme configuration is located in:
- `lib/plugins/theme/colors.dart` - Color definitions
- `lib/theme/` - Theme configurations

## 📊 Features by Screen

### Home Screen
- **Service Overview**: Quick access to all services
- **Recent Activity**: Latest bookings and updates
- **Quick Actions**: Fast access to common functions

### Service Listing
- **Grouped Services**: Services organized by type
- **Service Details**: Comprehensive service information
- **Rating System**: Service provider ratings and reviews
- **Availability Status**: Real-time availability indicators

### Booking Management
- **Booking Requests**: Incoming service requests
- **Booking Details**: Complete booking information
- **Status Updates**: Track booking progress
- **Communication**: Direct communication with drivers

### Profile & Settings
- **Service Provider Profile**: Professional information
- **Service History**: Past services and earnings
- **App Settings**: Notification and preference settings
- **Account Management**: Profile editing and account settings

##  Security Features

- **Secure Authentication**: Google Sign-In integration
- **Token-based API**: Secure API communication
- **Data Encryption**: Sensitive data protection
- **Background Services**: Secure background processing

##  Platform Support

- **Android**: Full support with native features
- **iOS**: Full support with native features
- **Responsive Design**: Optimized for various screen sizes

##  Deployment

### Google Play Store
1. Build the AAB file using the provided build script
2. Upload to Google Play Console
3. Complete store listing requirements
4. Submit for review

### App Store (iOS)
1. Build iOS archive
2. Upload to App Store Connect
3. Complete app store listing
4. Submit for review

##  Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

##  License

This project is proprietary software. All rights reserved.

##  Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation in the `docs/` folder

---

**RideRescue Services** - Empowering roadside assistance professionals with modern mobile technology.
