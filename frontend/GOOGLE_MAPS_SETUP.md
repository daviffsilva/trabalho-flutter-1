# Google Maps API Setup

This app uses Google Maps API for address search and geocoding functionality. Follow these steps to set up your API key:

## 1. Get a Google Maps API Key

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the following APIs:
   - **Places API** (for address autocomplete)
   - **Geocoding API** (for address to coordinates conversion)
   - **Maps SDK for Android** (for Android maps)
   - **Maps SDK for iOS** (for iOS maps)

## 2. Create API Key

1. In the Google Cloud Console, go to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "API Key"
3. Copy the generated API key

## 3. Configure the API Key

1. Open `lib/config/api_config.dart`
2. Replace `'YOUR_GOOGLE_MAPS_API_KEY'` with your actual API key:

```dart
class ApiConfig {
  static const String googleMapsApiKey = 'YOUR_ACTUAL_API_KEY_HERE';
  // ... rest of the config
}
```

## 4. Android Configuration

1. Open `android/app/src/main/AndroidManifest.xml`
2. Add the API key inside the `<application>` tag:

```xml
<application>
    <!-- ... other configurations ... -->
    <meta-data
        android:name="com.google.android.geo.API_KEY"
        android:value="YOUR_ACTUAL_API_KEY_HERE" />
</application>
```

## 5. iOS Configuration

1. Open `ios/Runner/AppDelegate.swift`
2. Add the API key in the `application` method:

```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_ACTUAL_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## 6. Security Best Practices

1. **Restrict the API Key**: In Google Cloud Console, go to "APIs & Services" > "Credentials"
2. Click on your API key to edit it
3. Under "Application restrictions", select "Android apps" and/or "iOS apps"
4. Add your app's package name and SHA-1 certificate fingerprint (for Android)
5. Under "API restrictions", select "Restrict key" and choose the APIs you enabled

## 7. Test the Setup

1. Run the app
2. Go to "Criar Pedido" (Create Order)
3. Try typing in the address fields - you should see autocomplete suggestions
4. Select an address from the suggestions - coordinates should be automatically filled

## Troubleshooting

- **No suggestions appear**: Check if Places API is enabled and API key is correct
- **Maps don't load**: Check if Maps SDK is enabled for your platform
- **API key errors**: Verify the key is properly configured in all platform files
- **Quota exceeded**: Check your Google Cloud Console billing and quotas

## Important Notes

- Keep your API key secure and never commit it to version control
- Consider using environment variables or secure storage for production apps
- Monitor your API usage in Google Cloud Console to avoid unexpected charges
- The free tier includes $200 worth of API calls per month 