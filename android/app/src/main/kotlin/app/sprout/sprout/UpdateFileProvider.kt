package app.sprout.sprout

import android.content.ContentProvider
import android.content.ContentValues
import android.content.Context
import android.database.Cursor
import android.net.Uri
import android.os.ParcelFileDescriptor
import java.io.File
import java.io.FileNotFoundException

/**
 * Shares only the downloaded update APK with Android's installer, read-only.
 * A tiny stand-in for androidx FileProvider so the app needs no extra library.
 */
class UpdateFileProvider : ContentProvider() {
    companion object {
        private const val NAME = "sprout-update.apk"

        fun authority(context: Context) = "${context.packageName}.updates"

        fun uriFor(context: Context, apk: File): Uri {
            require(apk.canonicalFile == File(context.cacheDir, NAME).canonicalFile) { "Only the update APK can be shared" }
            return Uri.parse("content://${authority(context)}/$NAME")
        }
    }

    override fun onCreate() = true

    override fun getType(uri: Uri) = "application/vnd.android.package-archive"

    override fun openFile(uri: Uri, mode: String): ParcelFileDescriptor {
        val file = File(context!!.cacheDir, NAME)
        if (uri.lastPathSegment != NAME || !file.exists()) throw FileNotFoundException(uri.toString())
        return ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
    }

    override fun query(uri: Uri, p: Array<String>?, s: String?, a: Array<String>?, o: String?): Cursor? = null

    override fun insert(uri: Uri, values: ContentValues?): Uri? = null

    override fun delete(uri: Uri, s: String?, a: Array<String>?) = 0

    override fun update(uri: Uri, v: ContentValues?, s: String?, a: Array<String>?) = 0
}
