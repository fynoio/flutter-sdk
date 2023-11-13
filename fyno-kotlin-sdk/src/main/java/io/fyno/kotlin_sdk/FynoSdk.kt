package io.fyno.kotlin_sdk

import android.content.Context
import android.util.Log
import io.fyno.callback.FynoCallback
import io.fyno.callback.models.MessageStatus
import io.fyno.core.FynoCore
import io.fyno.core.utils.LogLevel
import io.fyno.pushlibrary.FynoPush
import io.fyno.pushlibrary.models.PushRegion

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.runBlocking
import org.json.JSONObject

public object FynoSdk {
    fun initialize(context: Context, workspaceId: String, token: String, userId: String? = null, version: String = "live") {
        runBlocking(Dispatchers.IO) {
                FynoCore.initialize(context, workspaceId, token, version)
                userId?.let { FynoCore.identify(uniqueId = it, update = true)
                   }
        }
    }

    fun registerPush(xiaomiApplicationId: String? = "", xiaomiApplicationKey: String? = "", pushRegion: PushRegion? = PushRegion.INDIA, integrationId: String = "") {
        FynoPush().registerPush(xiaomiApplicationId, xiaomiApplicationKey, pushRegion, integrationId)
    }

    fun identify(uniqueId: String, userName: String? = null) {
        runBlocking(Dispatchers.IO) {
                FynoCore.identify(uniqueId, userName, true)
        }
    }

    fun resetUser() {
        runBlocking(Dispatchers.IO) {
                FynoCore.resetUser()
        }
    }

    fun resetConfig() {
        FynoCore.resetConfig()
    }

    fun saveConfig(wsId: String, apiKey: String, fcmIntegration: String, miIntegration: String) {
        FynoCore.saveConfig(wsId, apiKey, fcmIntegration, miIntegration)
    }

    fun setLogLevel(level: LogLevel) {
        FynoCore.setLogLevel(level)
    }

    fun mergeProfile(oldDistinctId: String, newDistinctId: String) {
        runBlocking(Dispatchers.IO) {
                FynoCore.mergeProfile(oldDistinctId, newDistinctId)
        }
    }

    fun updateStatus(callbackURL:String, status: MessageStatus, action:JSONObject){
        runBlocking (Dispatchers.IO) {
            FynoCallback().updateStatus(callbackURL, status, action)
        }
    }
}
