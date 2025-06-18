# iOS Permissions Configuration

This document describes the iOS permissions configuration changes made to enable local network access for WebSocket connections and debugging.

## Issue

The Flutter app was showing the following error:
```
[ERROR:flutter/shell/platform/darwin/ios/framework/Source/FlutterDartVMServicePublisher.mm(129)] Could not register as server for FlutterDartVMServicePublisher, permission denied. Check your 'Local Network' permissions for this app in the Privacy section of the system Settings.
```

This error occurs because iOS requires explicit permission for apps to access the local network, which is needed for:
- WebSocket connections to localhost
- Flutter debugging and hot reload
- Local network communication

## Solution

### 1. Info.plist Configuration

Added the `NSLocalNetworkUsageDescription` key to `ios/Runner/Info.plist`:

```xml
<key>NSLocalNetworkUsageDescription</key>
<string>Este aplicativo precisa acessar a rede local para conectar com o servidor de rastreamento em tempo real.</string>
```

This provides a user-friendly description of why the app needs local network access.

### 2. Entitlements File

Created `ios/Runner/Runner.entitlements` with the following content:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.security.network.client</key>
	<true/>
	<key>com.apple.security.network.server</key>
	<true/>
	<key>com.apple.developer.networking.multicast</key>
	<true/>
</dict>
</plist>
```

This entitlements file grants the app permission to:
- Act as a network client (make outgoing connections)
- Act as a network server (accept incoming connections)
- Use multicast networking

### 3. Xcode Project Configuration

Updated `ios/Runner.xcodeproj/project.pbxproj` to:

1. **Add entitlements file reference** to PBXFileReference section:
   ```
   97C147031CF9000F007C117D /* Runner.entitlements */ = {isa = PBXFileReference; lastKnownFileType = text.plist.entitlements; path = Runner.entitlements; sourceTree = "<group>"; };
   ```

2. **Add entitlements file to Runner group**:
   ```
   97C147031CF9000F007C117D /* Runner.entitlements */,
   ```

3. **Configure CODE_SIGN_ENTITLEMENTS** in all build configurations (Debug, Release, Profile):
   ```
   CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;
   ```

## Files Modified

1. `ios/Runner/Info.plist` - Added local network usage description
2. `ios/Runner/Runner.entitlements` - Created entitlements file
3. `ios/Runner.xcodeproj/project.pbxproj` - Updated project configuration

## Testing

After making these changes:

1. Clean the project: `flutter clean`
2. Get dependencies: `flutter pub get`
3. Run the app: `flutter run --debug`

The app should now have proper local network permissions and the error should be resolved.

## User Experience

When the app is first launched, iOS will show a permission dialog asking the user to allow local network access. The user will see the description text we provided in the Info.plist file.

## Additional Notes

- These permissions are required for development and testing with localhost
- For production apps, you may need additional network security configurations
- The entitlements file is only needed for local network access, not for internet access
- These changes are specific to iOS and don't affect Android

## Troubleshooting

If you still see permission errors:

1. Check that the entitlements file is properly referenced in the project
2. Verify that the Info.plist contains the NSLocalNetworkUsageDescription key
3. Clean and rebuild the project
4. Check iOS Settings > Privacy & Security > Local Network for the app
5. Ensure the development team is properly configured in Xcode

## Security Considerations

- The entitlements granted are minimal and only for local network access
- These permissions don't grant internet access beyond the local network
- The app still needs to follow iOS security guidelines for network communication
- Consider implementing proper network security measures for production use 