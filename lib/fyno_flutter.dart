import 'package:flutter/services.dart';

class FynoFlutter {
  static const MethodChannel _channel = MethodChannel('fyno_flutter');

  // Initializes the SDK with workspace information and user credentials.
  static Future<Exception?> init(
      String workspaceId, String token, String userId, String version) async {
    try {
      return await _channel.invokeMethod("init", {
        "workspaceId": workspaceId,
        "token": token,
        "userId": userId,
        "version": version,
      });
    } on Exception catch (exception) {
      return exception;
    }
  }

  // Identifies the user with a unique ID.
  static Future<Exception?> identify(String distinctID, String userName) async {
    try {
      return await _channel.invokeMethod("identify", {
        "distinctID": distinctID,
        "userName": userName,
      });
    } on Exception catch (exception) {
      return exception;
    }
  }

  // Registers push notifications.
  static Future<Exception?> registerPush(
    String integrationId, {
    String? xiaomiApplicationId = "",
    String? xiaomiApplicationKey = "",
    String? pushRegion = "",
    bool? isAPNs = false,
  }) async {
    try {
      return await _channel.invokeMethod("registerPush", {
        "xiaomiApplicationId": xiaomiApplicationId,
        "xiaomiApplicationKey": xiaomiApplicationKey,
        "pushRegion": pushRegion,
        "integrationId": integrationId,
        "isAPNs": isAPNs,
      });
    } on Exception catch (e) {
      return e;
    }
  }

  // Registers push notifications with Firebase Cloud Messaging (FCM).
  static Future<Exception?> registerFCMPush(String integrationId) async {
    try {
      return await _channel.invokeMethod("registerFCMPush", {
        "integrationId": integrationId,
      });
    } on Exception catch (exception) {
      return exception;
    }
  }

  // Merges user profiles based on distinct IDs.
  static Future<Exception?> mergeProfile(
    String oldDistinctId,
    String newDistinctId,
  ) async {
    try {
      return await _channel.invokeMethod("mergeProfile", {
        "oldDistinctId": oldDistinctId,
        "newDistinctId": newDistinctId,
      });
    } on Exception catch (exception) {
      return exception;
    }
  }

  // Updates user status with a callback URL, status, and action details.
  static Future<Exception?> updateStatus(
      String callbackUrl, String status) async {
    try {
      return await _channel.invokeMethod("updateStatus", {
        "callbackUrl": callbackUrl,
        "status": status,
      });
    } on Exception catch (exception) {
      return exception;
    }
  }

  // Resets user information.
  static Future<Exception?> resetUser() async {
    try {
      return await _channel.invokeMethod("resetUser");
    } on Exception catch (exception) {
      return exception;
    }
  }
}
