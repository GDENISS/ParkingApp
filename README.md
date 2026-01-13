# Zorem Parking App 🚗

A Flutter parking sharing application with real-time map integration and Firebase backend. Find, share, and manage parking spots in your area.

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- A web browser (Chrome/Edge) for web platform
- Android Studio for Android development
- Xcode for iOS development (macOS only)
- Visual Studio 2022 with C++ for Windows desktop

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/GDENISS/ParkingApp.git
   cd ParkingApp
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # Web (easiest - no emulator needed)
   flutter run -d chrome
   
   # Windows Desktop
   flutter run -d windows
   
   # Android
   flutter run
   
   # Check available devices
   flutter devices
   ```

## 📱 Platform Support

| Platform | Status | Requirements |
|----------|--------|--------------|
| 🌐 Web | ✅ Ready | Chrome/Edge browser |
| 🪟 Windows | ✅ Ready | Visual Studio 2022 + C++ |
| 🤖 Android | ✅ Ready | Android Studio + Emulator |
| 🍎 iOS | ✅ Ready | macOS + Xcode |

## 🛠️ Setup Flutter (First Time)

### Windows
```bash
# Download Flutter SDK
https://docs.flutter.dev/get-started/install/windows

# Extract to C:\flutter
# Add to PATH: C:\flutter\bin
# Restart terminal and verify:
flutter doctor
```

### macOS
```bash
# Download and extract Flutter
# Add to ~/.zshrc:
export PATH="$PATH:/path/to/flutter/bin"

# Verify installation
flutter doctor
```

### Linux
```bash
# Download and extract Flutter
# Add to ~/.bashrc:
export PATH="$PATH:/path/to/flutter/bin"

# Verify installation
flutter doctor
```

## ⚙️ Platform-Specific Setup

### For Web Development (No Extra Setup)
Just run: `flutter run -d chrome`

### For Android Development
1. Install [Android Studio](https://developer.android.com/studio)
2. Install Android SDK and create an emulator
3. Enable USB debugging on physical device (optional)

### For iOS Development (macOS only)
```bash
# Install Xcode from App Store
# Install command-line tools
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo gem install cocoapods
```

### For Windows Desktop
1. Install [Visual Studio 2022](https://visualstudio.microsoft.com/downloads/)
2. Select "Desktop development with C++" workload

## 🔧 Common Commands

```bash
# Get dependencies
flutter pub get

# Run on specific device
flutter run -d chrome
flutter run -d windows
flutter run -d <device-id>

# List available devices
flutter devices

# Run tests
flutter test

# Build for production
flutter build web
flutter build apk
flutter build windows

# Clean build
flutter clean
```

## 🔥 Firebase Configuration

This app uses Firebase for backend services. Configuration files are included:
- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`
- Web/All: `lib/firebase_options.dart`

## 📂 Project Structure

```
├── lib/
│   ├── main.dart              # App entry point
│   └── firebase_options.dart  # Firebase config
├── assets/
│   ├── icons/                 # App icons
│   └── map_style_uber.json    # Custom map styling
├── android/                   # Android platform code
├── ios/                       # iOS platform code
├── web/                       # Web platform code
└── test/                      # Unit & widget tests
```

## 🐛 Troubleshooting

**"flutter is not recognized"**
- Add Flutter to your system PATH
- Restart terminal after installation

**"No devices found"**
- Web: Install Chrome or Edge
- Android: Start emulator or connect device
- Run `flutter devices` to check

**Build errors**
```bash
flutter clean
flutter pub get
# Delete build/ folder and retry
```

**Firebase errors**
- Verify `google-services.json` (Android)
- Verify `GoogleService-Info.plist` (iOS)
- Check `firebase_options.dart` configuration

## 📦 Key Features

- 🗺️ Real-time map with parking spots
- 📍 Geolocation and navigation
- 🔔 Local notifications
- 💾 Offline data storage
- 🔐 Firebase authentication & database
- 🎨 Custom map styling

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/widget_test.dart
```

## 📖 Dependencies

- `flutter_map` - Interactive map widget
- `geolocator` - Location services
- `firebase_core` - Firebase integration
- `shared_preferences` - Local storage
- `flutter_local_notifications` - Push notifications

See [pubspec.yaml](pubspec.yaml) for full list.

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 🔗 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [Flutter Packages](https://pub.dev/)

---

**Need Help?** Open an issue or check existing [Issues](https://github.com/GDENISS/ParkingApp/issues)
