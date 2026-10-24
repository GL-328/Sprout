package app.sprout.sprout

import android.app.PendingIntent
import android.content.Intent
import android.content.pm.PackageInstaller
import android.net.Uri
import android.os.Build
import android.os.StatFs
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    companion object {
        /** The activity while it is on screen, so the installer's confirm screen can open from it. */
        @Volatile
        var resumed: MainActivity? = null
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "sprout/updater/events").setStreamHandler(UpdateEvents)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "sprout/updater").setMethodCallHandler { call, result ->
            when (call.method) {
                "canInstall" -> result.success(canInstall())
                "openInstallSettings" -> {
                    openInstallSettings()
                    result.success(null)
                }
                "freeBytes" -> result.success(StatFs(cacheDir.path).availableBytes)
                "takeLastResult" -> result.success(UpdateEvents.takeLastResult(this))
                "install", "openInstaller" -> {
                    val path = call.argument<String>("path")
                    if (path == null) {
                        result.error("no_path", "No APK path given", null)
                    } else if (call.method == "openInstaller") {
                        try {
                            openInstaller(File(path))
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("open_failed", e.message, null)
                        }
                    } else {
                        Thread {
                            try {
                                install(File(path))
                                runOnUiThread { result.success(null) }
                            } catch (e: Exception) {
                                runOnUiThread { result.error("install_failed", e.message, null) }
                            }
                        }.start()
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onResume() {
        super.onResume()
        resumed = this
        // A confirm screen that arrived while Sprout was in the background.
        UpdateEvents.takePendingConfirm()?.let { startActivity(it) }
    }

    override fun onPause() {
        if (resumed === this) resumed = null
        super.onPause()
    }

    private fun canInstall(): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.O || packageManager.canRequestPackageInstalls()

    private fun openInstallSettings() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startActivity(Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES, Uri.parse("package:$packageName")))
        }
    }

    /**
     * Hands the downloaded APK to Android's installer as an update of this app.
     * Every outcome comes back through [UpdateStatusReceiver].
     */
    private fun install(apk: File) {
        val installer = packageManager.packageInstaller
        val params = PackageInstaller.SessionParams(PackageInstaller.SessionParams.MODE_FULL_INSTALL)
        params.setAppPackageName(packageName)
        params.setSize(apk.length())
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            // Skips the confirm screen when Android allows it (for example when
            // Sprout installed the current version itself).
            params.setRequireUserAction(PackageInstaller.SessionParams.USER_ACTION_NOT_REQUIRED)
        }
        val sessionId = installer.createSession(params)
        try {
            installer.openSession(sessionId).use { session ->
                apk.inputStream().use { input ->
                    session.openWrite("sprout.apk", 0, apk.length()).use { output ->
                        input.copyTo(output)
                        session.fsync(output)
                    }
                }
                var flags = PendingIntent.FLAG_UPDATE_CURRENT
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) flags = flags or PendingIntent.FLAG_MUTABLE
                val status = PendingIntent.getBroadcast(
                    this,
                    sessionId,
                    Intent(this, UpdateStatusReceiver::class.java).setPackage(packageName),
                    flags,
                )
                session.commit(status.intentSender)
            }
        } catch (e: Exception) {
            installer.abandonSession(sessionId)
            throw e
        }
    }

    /** The fallback: opens the APK in Android's own installer screen. */
    private fun openInstaller(apk: File) {
        val uri = UpdateFileProvider.uriFor(this, apk)
        startActivity(
            Intent(Intent.ACTION_VIEW)
                .setDataAndType(uri, "application/vnd.android.package-archive")
                .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_ACTIVITY_NEW_TASK),
        )
    }
}
