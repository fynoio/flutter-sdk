package io.fyno.fyno_flutter

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.fyno.kotlin_sdk.FynoSdk
import io.fyno.pushlibrary.FynoPush
import io.fyno.core.FynoUser
import io.fyno.callback.models.MessageStatus
import io.fyno.pushlibrary.models.PushRegion

class FynoFlutterPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private var channel: MethodChannel? = null
    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "fyno_flutter")
        channel!!.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        // Not required for this plugin
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "init" -> {
                try {
                    val args = call.arguments as Map<*, *>
                    FynoSdk.initialize(
                        context,
                        args["workspaceId"] as String,
                        args["integrationID"] as String,
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
                        args["distinctID"] as String,
                        args["userName"] as String
                    )
                    result.success(null)
                } catch (e: Exception) {
                    result.error("", "", e)
                }
            }

            "registerPush" -> {
                try {
                    FynoPush().showPermissionDialog(context)
                    val args = call.arguments as Map<*, *>
                    FynoSdk.registerPush(
                        args["xiaomiApplicationId"] as String,
                        args["xiaomiApplicationKey"] as String,
                        PushRegion.values().find { it.name == args["pushRegion"] as String }
                    )
                    result.success(null)
                } catch (e: Exception) {
                    result.error("", "", e)
                }
            }

            "registerInapp" -> {
                try {
                    val args = call.arguments as Map<*, *>
                    FynoSdk.registerInapp(
                        args["integrationID"] as String,
                    )
                    result.success(null)
                } catch (e: Exception) {
                    result.error("", "", e)
                }
            }

            "updateStatus" -> {
                try {
                    val args = call.arguments as Map<*, *>
                    val status = call.argument<String>("status")
                    val messageStatus = MessageStatus.valueOf(status as String)
                    FynoSdk.updateStatus(
                        context,
                        args["callbackUrl"] as String,
                        messageStatus
                    )
                    result.success(null)
                } catch (e: Exception) {
                    result.error("", "", e)
                }
            }

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

            "getNotificationToken" -> {
                try {
                    var token = FynoUser.getFcmToken()
                    if (token == "") {
                        token = FynoUser.getMiToken()
                    }
                    if (token == "") {
                        result.error("", "No push token found", null)
                        return
                    }

                    result.success(token)
                } catch (e: Exception) {
                    result.error("", "No push token found", e)
                }
            }

            "updateName"-> {
                try {
                    val args = call.arguments as Map<*, *>
                    FynoSdk.updateName(args["userName"] as String)
                    result.success(null)
                } catch (e: Exception) {
                    result.error("", "", e)
                }
            }

            else -> result.notImplemented()
        }
    }
}