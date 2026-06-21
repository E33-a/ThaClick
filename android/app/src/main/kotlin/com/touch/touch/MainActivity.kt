package com.touch.touch

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.text.TextUtils
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.touch.touch/clicker"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        ClickManager.methodChannel = channel
        
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "isAccessibilityEnabled" -> {
                    result.success(isAccessibilityEnabled())
                }
                "openAccessibilitySettings" -> {
                    openAccessibilitySettings()
                    result.success(null)
                }
                "isOverlayEnabled" -> {
                    result.success(isOverlayEnabled())
                }
                "openOverlaySettings" -> {
                    openOverlaySettings()
                    result.success(null)
                }
                "showOverlay" -> {
                    val service = ClickManager.service
                    if (service != null) {
                        service.showOverlay()
                        result.success(true)
                    } else {
                        result.error("SERVICE_NOT_RUNNING", "El servicio de accesibilidad no está activo.", null)
                    }
                }
                "hideOverlay" -> {
                    val service = ClickManager.service
                    if (service != null) {
                        service.hideOverlay()
                        result.success(true)
                    } else {
                        result.success(false)
                    }
                }
                "setSteps" -> {
                    val stepsJson = call.arguments as? String
                    if (stepsJson != null) {
                        ClickManager.updateStepsFromJson(stepsJson)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Se esperaba una cadena JSON.", null)
                    }
                }
                "startClicking" -> {
                    ClickManager.startClicking()
                    result.success(true)
                }
                "stopClicking" -> {
                    ClickManager.stopClicking()
                    result.success(true)
                }
                "isRunning" -> {
                    result.success(ClickManager.isRunning)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun isAccessibilityEnabled(): Boolean {
        val expectedComponentName = ComponentName(this, AutoClickerService::class.java)
        val enabledServicesSetting = Settings.Secure.getString(contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES) ?: return false
        val colonSplitter = TextUtils.SimpleStringSplitter(':')
        colonSplitter.setString(enabledServicesSetting)
        while (colonSplitter.hasNext()) {
            val componentNameString = colonSplitter.next()
            val enabledService = ComponentName.unflattenFromString(componentNameString)
            if (enabledService != null && enabledService == expectedComponentName) {
                return true
            }
        }
        return false
    }

    private fun openAccessibilitySettings() {
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }

    private fun isOverlayEnabled(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(this)
        } else {
            true
        }
    }

    private fun openOverlaySettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName")
            )
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
        }
    }
}
