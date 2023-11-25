package io.fyno.fyno_flutter

import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.fyno.kotlin_sdk.FynoSdk
import io.fyno.pushlibrary.FynoPush
import io.fyno.pushlibrary.models.MessageStatus
import io.fyno.pushlibrary.models.PushRegion

class FynoFlutterPlugin {
    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "fyno_flutter")
            channel.setMethodCallHandler { call, result ->
                when (call.method) {
                    "init" -> {
                        try {
                            val args = call.arguments as Map<*, *>
                            FynoSdk.initialize(
                                registrar.context(),
                                args["workspaceId"] as String,
                                args["token"] as String,
                                args["userId"] as String?,
                                args["version"] as String
                            )
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("", "", e)
                        }
                    }
                    "identify" -> {
                        try {
                            val args = call.arguments as Map<*, *>
                            FynoSdk.identify(
                                args["uniqueId"] as String,
                                args["userName"] as String
                            )
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("", "", e)
                        }
                    }
                    "registerPush" -> {
                        try {
                            FynoPush().showPermissionDialog()
                            val args = call.arguments as Map<*, *>
                            FynoSdk.registerPush(
                                args["xiaomiApplicationId"] as String,
                                args["xiaomiApplicationKey"] as String,
                                PushRegion.values().find { it.name == args["pushRegion"] as String },
                                args["integrationId"] as String
                            )
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("", "", e)
                        }
                    }
                    "registerFCMPush" -> {
                        try {
                            FynoPush().showPermissionDialog()
                            val args = call.arguments as Map<*, *>
                            FynoSdk.registerPush(
                                null,
                                null,
                                null,
                                args["integrationId"] as String
                            )
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("", "", e)
                        }
                    }
//                   "updateStatus" -> {
//                       try {
//                           val args = call.arguments as Map<*, *>
//                           val status = call.argument<String>("status")
//                           val messageStatus = status?.let { MessageStatus.valueOf(it) }
//                           if (messageStatus != null) {
//                               FynoSdk.updateStatus(
//                                   args["callbackUrl"] as String,
//                                   messageStatus
//                               )
//                           }
//                           result.success(null)
//                       } catch (e: Exception) {
//                           result.error("", "", e)
//                       }
//                   }
                    "mergeProfile" -> {
                        try {
                            val args = call.arguments as Map<*, *>
                            FynoSdk.mergeProfile(
                                args["oldDistinctId"] as String,
                                args["newDistinctId"] as String
                            )
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("", "", e)
                        }
                    }
                    "resetUser" -> {
                        try {
                            FynoSdk.resetUser()
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("", "", e)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }
}
