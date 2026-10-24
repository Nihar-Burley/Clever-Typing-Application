package com.clevertyping.app

import android.content.Context
import android.content.Intent
import android.provider.Settings
import android.text.TextUtils
import android.view.inputmethod.InputMethodManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class KeyboardPlatformChannelHandler(
    private val context: Context,
) : MethodChannel.MethodCallHandler {

    private val preferences by lazy {
        context.getSharedPreferences(PREFERENCES_NAME, Context.MODE_PRIVATE)
    }

    fun register(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME,
        ).setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "openKeyboardSettings" -> {
                context.startActivity(
                    Intent(Settings.ACTION_INPUT_METHOD_SETTINGS).apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    },
                )
                result.success(null)
            }

            "showInputMethodPicker" -> {
                val manager =
                    context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
                manager.showInputMethodPicker()
                result.success(null)
            }

            "getKeyboardStatus" -> {
                result.success(
                    mapOf(
                        "isKeyboardEnabled" to isKeyboardEnabled(),
                        "isKeyboardSelected" to isKeyboardSelected(),
                    ),
                )
            }

            "openAccessibilitySettings" -> {
                context.startActivity(
                    Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS).apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    },
                )
                result.success(null)
            }

            "isAccessibilityCaptureEnabled" -> {
                result.success(isAccessibilityCaptureEnabled())
            }

            "readLatestConversationContext" -> {
                result.success(
                    preferences.getString(LATEST_CONVERSATION_CONTEXT_KEY, null),
                )
            }

            "readNativeStatus" -> {
                result.success(
                    mapOf(
                        "isAccessibilityEnabled" to isAccessibilityCaptureEnabled(),
                        "incognitoModeEnabled" to
                            preferences.getBoolean("incognitoModeEnabled", false),
                        "blockedSensitiveActions" to
                            preferences.getInt("blockedSensitiveActions", 0),
                        "nativeAiExecutions" to
                            preferences.getInt("nativeAiExecutions", 0),
                        "nativeAiFailures" to
                            preferences.getInt("nativeAiFailures", 0),
                        "themePalette" to
                            preferences.getString("themePalette", "sunrise").orEmpty(),
                        "primaryLanguage" to
                            preferences.getString("primaryLanguage", "English").orEmpty(),
                        "secondaryLanguage" to
                            preferences.getString("secondaryLanguage", "Hindi").orEmpty(),
                    ),
                )
            }

            "clearNativeData" -> {
                preferences.edit()
                    .remove(LATEST_CONVERSATION_CONTEXT_KEY)
                    .putInt("blockedSensitiveActions", 0)
                    .putInt("nativeAiExecutions", 0)
                    .putInt("nativeAiFailures", 0)
                    .apply()
                result.success(null)
            }

            "syncPinnedAssistant" -> {
                val arguments = call.arguments as? Map<*, *> ?: emptyMap<String, Any>()
                preferences.edit()
                    .putString("pinnedAssistantId", arguments["assistantId"] as? String)
                    .apply()
                result.success(null)
            }

            "syncKeyboardSettings" -> {
                val arguments = call.arguments as? Map<*, *> ?: emptyMap<String, Any>()
                preferences.edit()
                    .putBoolean(
                        "autoCapitalizationEnabled",
                        arguments["autoCapitalizationEnabled"] as? Boolean ?: true,
                    )
                    .putBoolean(
                        "autoSpaceEnabled",
                        arguments["autoSpaceEnabled"] as? Boolean ?: true,
                    )
                    .putBoolean(
                        "hapticFeedbackEnabled",
                        arguments["hapticFeedbackEnabled"] as? Boolean ?: true,
                    )
                    .putBoolean(
                        "soundFeedbackEnabled",
                        arguments["soundFeedbackEnabled"] as? Boolean ?: false,
                    )
                    .putBoolean(
                        "oneHandedModeEnabled",
                        arguments["oneHandedModeEnabled"] as? Boolean ?: false,
                    )
                    .putFloat(
                        "keyboardHeight",
                        (arguments["keyboardHeight"] as? Double ?: 1.0).toFloat(),
                    )
                    .putString(
                        "themePalette",
                        arguments["themePalette"] as? String ?: "sunrise",
                    )
                    .putString(
                        "primaryLanguage",
                        arguments["primaryLanguage"] as? String ?: "English",
                    )
                    .putString(
                        "secondaryLanguage",
                        arguments["secondaryLanguage"] as? String ?: "Hindi",
                    )
                    .putBoolean(
                        "incognitoModeEnabled",
                        arguments["incognitoModeEnabled"] as? Boolean ?: false,
                    )
                    .apply()
                result.success(null)
            }

            "syncBackendConfig" -> {
                val arguments = call.arguments as? Map<*, *> ?: emptyMap<String, Any>()
                preferences.edit()
                    .putString("aiBaseUrl", arguments["baseUrl"] as? String ?: "")
                    .putString("aiApiKey", arguments["apiKey"] as? String ?: "")
                    .apply()
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }

    private fun isKeyboardEnabled(): Boolean {
        val enabledMethods = Settings.Secure.getString(
            context.contentResolver,
            Settings.Secure.ENABLED_INPUT_METHODS,
        ) ?: return false

        return enabledMethods.contains(KEYBOARD_SERVICE_ID)
    }

    private fun isKeyboardSelected(): Boolean {
        val defaultMethod = Settings.Secure.getString(
            context.contentResolver,
            Settings.Secure.DEFAULT_INPUT_METHOD,
        ) ?: return false

        return defaultMethod == KEYBOARD_SERVICE_ID
    }

    private fun isAccessibilityCaptureEnabled(): Boolean {
        val enabledServices =
            Settings.Secure.getString(
                context.contentResolver,
                Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES,
            ) ?: return false

        val splitter = TextUtils.SimpleStringSplitter(':')
        splitter.setString(enabledServices)
        while (splitter.hasNext()) {
            if (splitter.next().equals(ACCESSIBILITY_SERVICE_ID, ignoreCase = true)) {
                return true
            }
        }
        return false
    }

    companion object {
        private const val CHANNEL_NAME = "clever_typing/keyboard"
        private const val PREFERENCES_NAME = "clever_keyboard_preferences"
        private const val LATEST_CONVERSATION_CONTEXT_KEY = "latestConversationContext"
        private const val KEYBOARD_SERVICE_ID =
            "com.clevertyping.app/com.clevertyping.keyboard.ime.CleverKeyboardService"
        private const val ACCESSIBILITY_SERVICE_ID =
            "com.clevertyping.app/com.clevertyping.app.NativeConversationCaptureService"
    }
}
