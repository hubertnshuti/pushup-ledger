package com.hubertnshuti.pushup_ledger

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.IOException

class MainActivity : FlutterActivity() {
    private var pendingBackupContent: String? = null
    private var pendingBackupResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        MethodChannel(messenger, WIDGET_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method != "publish") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            val lines = call.argument<Map<String, String>>("lines")
            if (lines == null) {
                result.error("missing_lines", "No widget lines were sent.", null)
                return@setMethodCallHandler
            }
            PushupWidgetProvider.saveLines(applicationContext, lines)
            result.success(null)
        }
        MethodChannel(messenger, BACKUP_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "save") {
                startBackupSave(call, result)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun startBackupSave(call: MethodCall, result: MethodChannel.Result) {
        val fileName = call.argument<String>("fileName")
        val content = call.argument<String>("content")
        if (fileName == null || content == null) {
            result.error("missing_backup", "No backup content was sent.", null)
            return
        }
        if (pendingBackupResult != null) {
            result.error("backup_busy", "A backup is already being saved.", null)
            return
        }
        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "application/json"
            putExtra(Intent.EXTRA_TITLE, fileName)
        }
        pendingBackupContent = content
        pendingBackupResult = result
        try {
            startActivityForResult(intent, CREATE_BACKUP_REQUEST)
        } catch (_: ActivityNotFoundException) {
            pendingBackupContent = null
            pendingBackupResult = null
            result.error("no_file_picker", "No file picker is available.", null)
        }
    }

    @Deprecated("Required by FlutterActivity's result callback.")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != CREATE_BACKUP_REQUEST) {
            return
        }
        val result = pendingBackupResult ?: return
        val content = pendingBackupContent
        pendingBackupResult = null
        pendingBackupContent = null

        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null || content == null) {
            result.success(false)
            return
        }
        writeBackup(uri, content, result)
    }

    /** Writes off the main thread so a slow storage provider cannot freeze the UI. */
    private fun writeBackup(uri: Uri, content: String, result: MethodChannel.Result) {
        Thread {
            val error = try {
                val stream = contentResolver.openOutputStream(uri, "wt")
                    ?: throw IOException("The chosen file could not be opened.")
                stream.use { it.write(content.toByteArray(Charsets.UTF_8)) }
                null
            } catch (exception: IOException) {
                exception
            } catch (exception: SecurityException) {
                exception
            }
            runOnUiThread {
                if (error == null) {
                    result.success(true)
                } else {
                    result.error("backup_write_failed", error.message, null)
                }
            }
        }.start()
    }

    private companion object {
        const val WIDGET_CHANNEL = "pushup_ledger/home_widget"
        const val BACKUP_CHANNEL = "pushup_ledger/backup"
        const val CREATE_BACKUP_REQUEST = 4201
    }
}
