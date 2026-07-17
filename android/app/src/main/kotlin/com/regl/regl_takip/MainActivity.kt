package com.regl.regl_takip

import android.content.ComponentName
import android.content.pm.PackageManager
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "regl_takip/disguise"
        private const val PRIVACY_CHANNEL = "regl_takip/privacy"
        private const val ALIAS_DEFAULT = "com.regl.regl_takip.MainActivityDefault"
        private const val ALIAS_DISGUISED = "com.regl.regl_takip.MainActivityDisguised"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setDisguise" -> {
                        val enabled = call.argument<Boolean>("enabled") ?: false
                        setDisguise(enabled)
                        result.success(true)
                    }
                    "isDisguised" -> result.success(isDisguised())
                    else -> result.notImplemented()
                }
            }
        // FLAG_SECURE: uygulama değiştirici (recents) önizlemesi ve ekran
        // görüntüsü sağlık verisi sızdırmasın. Kilit (PIN/biyometri) açıkken
        // Dart tarafı bunu etkinleştirir; ekran görüntüsünün de kapanması
        // bilinçli bedel.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PRIVACY_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setSecureScreen" -> {
                        val enabled = call.argument<Boolean>("enabled") ?: false
                        runOnUiThread {
                            if (enabled) {
                                window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                            } else {
                                window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                            }
                        }
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /// Launcher ikonunu/adını alias'lar arasında değiştirir.
    /// DONT_KILL_APP: uygulama kapanmadan launcher birkaç saniye içinde
    /// yeni ikonu gösterir (bazı launcher'lar yeniden başlatma ister).
    private fun setDisguise(enabled: Boolean) {
        val pm = packageManager
        pm.setComponentEnabledSetting(
            ComponentName(this, ALIAS_DISGUISED),
            if (enabled) PackageManager.COMPONENT_ENABLED_STATE_ENABLED
            else PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
            PackageManager.DONT_KILL_APP
        )
        pm.setComponentEnabledSetting(
            ComponentName(this, ALIAS_DEFAULT),
            if (enabled) PackageManager.COMPONENT_ENABLED_STATE_DISABLED
            else PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
            PackageManager.DONT_KILL_APP
        )
    }

    private fun isDisguised(): Boolean {
        val state = packageManager.getComponentEnabledSetting(
            ComponentName(this, ALIAS_DISGUISED)
        )
        return state == PackageManager.COMPONENT_ENABLED_STATE_ENABLED
    }
}
