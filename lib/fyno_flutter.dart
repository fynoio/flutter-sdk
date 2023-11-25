import 'package:flutter/services.dart';

class FynoFlutter {
  static const MethodChannel _channel = MethodChannel('fyno_flutter');

  // Initializes the SDK with workspace information and user credentials.
  static Exception? init(
      String workspaceId, String token, String userId, String version) {
    try {
      _channel.invokeMethod("init", {
        "workspaceId": workspaceId,
        "token": token,
        "userId": userId,
        "version": version,
      });
      return null;
    } on Exception catch (exception) {
      return exception;
    }
  }

  // Identifies the user with a unique ID.
  static Exception? identify(String userId) {
    try {
      _channel.invokeMethod("identify", {
        "userName": userId,
        "uniqueId": userId,
      });
      return null;
    } on Exception catch (exception) {
      return exception;
    }
  }

  // Registers push notifications with Xiaomi services.
  static Exception? registerPush(String xiaomiApplicationId,
      String xiaomiApplicationKey, String pushRegion, String integrationId) {
    try {
      _channel.invokeMethod("registerPush", {
        "xiaomiApplicationId": xiaomiApplicationId,
        "xiaomiApplicationKey": xiaomiApplicationKey,
        "pushRegion": pushRegion,
        "integrationId": integrationId,
      });
      return null;
    } on Exception catch (exception) {
      return exception;
    }
  }

  // Registers push notifications with Firebase Cloud Messaging (FCM).
  static Exception? registerFCMPush(String integrationId) {
    try {
      _channel.invokeMethod("registerFCMPush", {
        "integrationId": integrationId,
      });
      return null;
    } on Exception catch (exception) {
      return exception;
    }
  }

  // Merges user profiles based on distinct IDs.
  static Exception? mergeProfile(String oldDistinctId, String newDistinctId) {
    try {
      _channel.invokeMethod("mergeProfile", {
        "oldDistinctId": oldDistinctId,
        "newDistinctId": newDistinctId,
      });
      return null;
    } on Exception catch (exception) {
      return exception;
    }
  }

  // Updates user status with a callback URL, status, and action details.
  static Exception? updateStatus(
      String callbackUrl, String status, String action) {
    try {
      _channel.invokeMethod("updateStatus", {
        "callbackUrl": callbackUrl,
        "status": status,
      });
      return null;
    } on Exception catch (exception) {
      return exception;
    }
  }

  // Resets user information.
  static Exception? resetUser() {
    try {
      _channel.invokeMethod("resetUser");
      return null;
    } on Exception catch (exception) {
      return exception;
    }
  }
}
