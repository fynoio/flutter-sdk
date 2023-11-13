package com.example.fyno_flutter_sdk

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.fyno.callback.models.MessageStatus
import io.fyno.kotlin_sdk.FynoSdk
import io.fyno.pushlibrary.FynoPush
import io.fyno.pushlibrary.models.PushRegion
import org.json.JSONObject

class MainActivity: FlutterActivity() {
    private val fynoChannel = "fyno.flutter/helper"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, fynoChannel).setMethodCallHandler {
                call, result ->
            when (call.method) {
                "init" -> {
                    try {
                        val args = call.arguments as Map<*, *>
                        FynoSdk.initialize(
                            this,
                            args["workspaceId"] as String,
                            args["token"] as String,
                            args["userId"] as String?,
                            args["version"] as String
                        )
                        result.success(null)
                    } catch (e:Exception) {
                        result.error("ERROR_CODE", "exception in initialize", e)
                    }
                }

                "identify" -> {
                    try{
                        val args = call.arguments as Map<*, *>
                        FynoSdk.identify(
                            args["uniqueId"] as String,
                            args["userName"] as String
                        )
                        result.success(null)
                    } catch (e:Exception) {
                        result.error("", "", e)
                    }
                }

                "registerPush" -> {
                    try{
                        FynoPush().showPermissionDialog()
                        val args = call.arguments as Map<*, *>
                        FynoSdk.registerPush(
                            args["xiaomiApplicationId"] as String,
                            args["xiaomiApplicationKey"] as String,
                            PushRegion.values().find { it.name == args["pushRegion"] as String },
                            args["integrationId"] as String
                        )
                        result.success(null)
                    } catch (e:Exception){
                        result.error("","",e)
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
                    } catch (e:Exception){
                        result.error("","",e)
                    }
                }

                "mergeProfile"-> {
                    try {
                        val args = call.arguments as Map<*, *>
                        FynoSdk.mergeProfile(
                            args["oldDistinctId"] as String,
                            args["newDistinctId"] as String
                        )
                        result.success(null)
                    } catch (e:Exception) {
                        result.error("", "", e)
                    }
                }

                "updateStatus" -> {
                    try {
                        val args = call.arguments as Map<*, *>
                        val status = call.argument<String>("status")
                        val action = call.argument<Map<String, Any>>("action")

                        val messageStatus = status?.let { MessageStatus.valueOf(it) }
                        action?.let {
                            val actionMap = it as Map<*, *>
                            val actionJson = JSONObject(actionMap)
                            if (messageStatus != null) {
                                FynoSdk.updateStatus(
                                    args["callbackUrl"] as String,
                                    messageStatus,
                                    actionJson
                                )
                            }
                        }
                        result.success(null)
                    } catch (e:Exception) {
                        result.error("", "", e)
                    }
                }

                "resetUser"-> {
                    try {
                        FynoSdk.resetUser()
                        result.success(null)
                    }catch (e:Exception){
                        result.error("","",e)
                    }
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}



