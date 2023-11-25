# fyno_flutter

A Dart package for communication with native platform code through method channels in Flutter applications developed by Fyno.

## Installation

Add the following to your `pubspec.yaml` file:

For latest version of the package, refer [fyno_flutter](https://pub.dev/packages/fyno_flutter)

```yaml
dependencies:
  fyno_flutter: <latest_version>
```

Then run:

```bash
dart pub get
```

## Usage

Import the package in your Dart file:

```dart
import 'package:fyno_flutter/fyno_flutter.dart';
```

## Initialization

```dart
Exception? initResult = FynoFlutter.init(
  "your_workspace_id",
  "your_token",
  "your_user_id",
  "your_version",
);

if (initResult == null) {
  // Initialization successful
} else {
  // Handle initialization error
  print("Initialization error: $initResult");
}
```

## Identifying the User

```dart
Exception? identifyResult = FynoFlutter.identify("your_user_id");

if (identifyResult == null) {
  // User identification successful
} else {
  // Handle identification error
  print("Identification error: $identifyResult");
}
```

## Registering Push Notifications with Xiaomi Services

```dart
Exception? pushRegistrationResult = FynoFlutter.registerPush(
  "xiaomi_application_id",
  "xiaomi_application_key",
  "push_region",
  "integration_id",
);

if (pushRegistrationResult == null) {
  // Push registration successful
} else {
  // Handle push registration error
  print("Push registration error: $pushRegistrationResult");
}
```

Registering Push Notifications with Firebase Cloud Messaging (FCM)

```dart
Exception? fcmPushRegistrationResult =
    FynoFlutter.registerFCMPush("integration_id");

if (fcmPushRegistrationResult == null) {
  // FCM push registration successful
} else {
  // Handle FCM push registration error
  print("FCM push registration error: $fcmPushRegistrationResult");
}
```

## Merging User Profiles

```dart
Exception? mergeResult = FynoFlutter.mergeProfile(
  "old_distinct_id",
  "new_distinct_id",
);

if (mergeResult == null) {
  // User profile merge successful
} else {
  // Handle user profile merge error
  print("User profile merge error: $mergeResult");
}
```

## Updating Message Status

```dart
Exception? updateStatusResult = FynoFlutter.updateStatus(
  "callback_url",
  "status",
);

if (updateStatusResult == null) {
  // User status update successful
} else {
  // Handle user status update error
  print("User status update error: $updateStatusResult");
}
```

## Resetting User Information

```dart
Exception? resetUserResult = FynoFlutter.resetUser();

if (resetUserResult == null) {
  // User information reset successful
} else {
  // Handle user information reset error
  print("User information reset error: $resetUserResult");
}
```

License

This project is licensed under the 3-Clause BSD [License](LICENSE) - see the LICENSE file for details.
