import 'dart:io';

import 'package:flutter/services.dart';

class FynoFlutter {
  static const MethodChannel _channel = MethodChannel('fyno_flutter');

  // Initializes the SDK with workspace information and user credentials.
  static Future<Exception?> init(String workspaceId, String integrationID,
      String userId, String version) async {
    try {
      // For Android, use userId only if it is not empty; otherwise, use null
      final user = Platform.isAndroid && userId.isEmpty ? null : userId;

      return await _channel.invokeMethod("init", {
        "workspaceId": workspaceId,
        "integrationID": integrationID,
        "userId": user,
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

  // Update username
  static Future<Exception?> updateName(String userName) async {
    try {
      return await _channel.invokeMethod('updateName', {"userName": userName});
    } on Exception catch (exception) {
      return exception;
    }
  }

  // Registers push notifications.
  static Future<Exception?> registerPush(
    String provider, {
    String? xiaomiApplicationId = "",
    String? xiaomiApplicationKey = "",
    String? pushRegion = "",
  }) async {
    try {
      return await _channel.invokeMethod("registerPush", {
        "xiaomiApplicationId": xiaomiApplicationId,
        "xiaomiApplicationKey": xiaomiApplicationKey,
        "pushRegion": pushRegion,
        "provider": provider,
      });
    } on Exception catch (e) {
      return e;
    }
  }

  // Registers inapp
  static Future<Exception?> registerInapp(String integrationID) async {
    try {
      return await _channel.invokeMethod("registerInapp", {
        "integrationID": integrationID,
      });
    } on Exception catch (e) {
      return e;
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

  // Fetch notification token
  static Future<String?> getNotificationToken() async {
    try {
      return await _channel.invokeMethod('getNotificationToken');
    } on Exception catch (exception) {
      print("Exception in getNotificationToken $exception");
      return '';
    }
  }
}
