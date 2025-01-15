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
import io.fyno.core.utils.Logger
import io.fyno.pushlibrary.models.PushRegion

import io.fyno.pushlibrary.helper.NotificationHelper.renderFCMMessage
import io.fyno.pushlibrary.notification.Actions
import io.fyno.pushlibrary.notification.NotificationActionType
import io.fyno.pushlibrary.notification.RawMessage
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import org.json.JSONArray
import org.json.JSONObject

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

    private fun String?.toNotificationObject(): JSONObject {
        return try {
            if (isNullOrBlank()) {
                Logger.w("NotificationHelper", "toNotificationObject: Input string is null or blank")
                return JSONObject()
            }

            // Clean up unnecessary escape characters
            val cleanedString = this.replace("\\n", "")

            // Convert to JSONObject
            val jsonObject = JSONObject(cleanedString)

            // Handle nested `additional_data` field if present
            if (jsonObject.has("additional_data")) {
                val additionalDataString = jsonObject.getString("additional_data")
                try {
                    val additionalDataJson = JSONObject(additionalDataString)
                    jsonObject.put("additional_data", additionalDataJson) // Replace string with JSON object
                } catch (e: Exception) {
                    Logger.w("NotificationHelper", "toNotificationObject: Failed to parse nested additional_data JSON", e)
                }
            }

            jsonObject
        } catch (e: Exception) {
            Logger.e("NotificationHelper", "toNotificationObject: Error while converting notification string to JSON object", e)
            JSONObject()
        }
    }

    private fun JSONObject.safeString(key: String): String? {
        return if (!isNull(key))
            getString(key)
        else null
    }

    private fun JSONObject.safeBoolean(key: String): Boolean? {
        return if (!isNull(key))
            getBoolean(key)
        else null
    }

    private fun JSONObject.safeLong(key: String): Long? {
        return if (!isNull(key))
            getLong(key)
        else null
    }

    private fun JSONObject.safeJsonArray(key: String): JSONArray? {
        return if (!isNull(key))
            getJSONArray(key)
        else null
    }

    private fun getActions(notificationPayloadJO: JSONObject): List<Actions>? {
        val safeActions = notificationPayloadJO.safeJsonArray("actions")
        safeActions ?: return null
        val actionsList = arrayListOf<Actions>()
        for (i in 0 until safeActions.length()) {
            val actionObj = safeActions.getJSONObject(i)
            actionsList.add(
                Actions(
                    id = actionObj.safeString("id"),
                    title = actionObj.safeString("title"),
                    link = actionObj.safeString("link"),
                    iconDrawableName = actionObj.safeString("iconIdentifierName"),
                    notificationId = actionObj.safeString("notificationId"),
                    notificationActionType = when(actionObj.safeString("notificationActionType")){
                        "button" -> NotificationActionType.BUTTON
                        "body" -> NotificationActionType.BODY
                        else -> NotificationActionType.BODY
                    }
                )
            )
        }
        return actionsList
    }

    private fun String?.createNotification(): RawMessage {
        this ?: return RawMessage("1", "1")

        val notificationPayloadJO = toNotificationObject()

        val id = notificationPayloadJO.safeString("id") ?: ""
        return RawMessage(
            id = id,
            channelId = notificationPayloadJO.safeString("channel"),
            channelName = notificationPayloadJO.safeString("channelName"),
            channelDescription = notificationPayloadJO.safeString("channelDescription"),
            showBadge = notificationPayloadJO.safeBoolean("badge"),
            cSound = notificationPayloadJO.safeString("cSound"),
            smallIconDrawable = notificationPayloadJO.safeString("icon"),
            color = notificationPayloadJO.safeString("color"),
            notificationTitle = notificationPayloadJO.safeString("title"),
            subTitle = notificationPayloadJO.safeString("subTitle"),
            shortDescription = notificationPayloadJO.safeString("content"),
            longDescription = notificationPayloadJO.safeString("longDescription"),
            iconUrl = notificationPayloadJO.safeString("bigIcon"),
            imageUrl = notificationPayloadJO.safeString("bigPicture"),
            action = notificationPayloadJO.safeString("action"),
            sound = notificationPayloadJO.safeString("sound"),
            callback = notificationPayloadJO.safeString("callback"),
            category = notificationPayloadJO.safeString("category"),
            group = notificationPayloadJO.safeString("group"),
            groupSubText = notificationPayloadJO.safeString("groupSubText"),
            groupShowWhenTimeStamp = notificationPayloadJO.safeBoolean("groupShowWhenTimeStamp"),
            groupWhenTimeStamp = notificationPayloadJO.safeLong("groupWhenTimeStamp"),
            sortKey = notificationPayloadJO.safeString("sortKey"),
            onGoing = notificationPayloadJO.safeBoolean("sticky"),
            autoCancel = notificationPayloadJO.safeBoolean("autoCancel"),
            timeoutAfter = notificationPayloadJO.safeLong("timeoutAfter"),
            showWhenTimeStamp = notificationPayloadJO.safeBoolean("showWhenTimeStamp"),
            whenTimeStamp = notificationPayloadJO.safeLong("whenTimeStamp"),
            actions = getActions(notificationPayloadJO),
            template = notificationPayloadJO.safeString("template"),
            additional_data = notificationPayloadJO.safeString("additional_data")
        )
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

            "isFynoNotification" -> {
                try {
                    val args = call.arguments as Map<*, *>
                    var message = args["messageData"] as HashMap<*, *>
                    message = message["data"] as HashMap<*,*>
                    result.success(message["fyno_push"] != null)
                } catch (e: Exception) {
                    result.error("", "", e)
                }
            }

            "handleFynoNotification" -> {
                try {
                    val args = call.arguments as Map<*, *>
                    var message = args["messageData"] as HashMap<*, *>
                    message = message["data"] as HashMap<*, *>
                    val fynoMessage = message["fyno_push"].toString()
                    CoroutineScope(Dispatchers.IO).launch {
                        renderFCMMessage(context, fynoMessage.createNotification())
                    }
                    result.success(null)
                } catch (e: Exception) {
                    result.error("", "", e)
                }
            }

            "updateName" -> {
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