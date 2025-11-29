package com.example.android_sms_kit

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import android.database.Cursor
import android.net.Uri
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import org.json.JSONArray
import org.json.JSONObject
import java.util.regex.Pattern

class AndroidSmsKitPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware, PluginRegistry.RequestPermissionsResultListener {
    
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var permissionResult: MethodChannel.Result? = null

    companion object {
        const val SMS_PERMISSION_CODE = 101
        
        private val TRANSACTION_KEYWORDS = arrayOf(
            "debited", "credited", "paid", "received", "transferred",
            "transaction", "payment", "purchase", "withdrawn", "deposit",
            "balance", "account", "bank", "upi", "card", "atm",
            "amount", "rupees", "rs", "inr", "₹"
        )
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "android_sms_kit")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        android.util.Log.d("AndroidSmsKitPlugin", "Method called: ${call.method}")
        
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "checkSmsPermission" -> {
                val status = checkSmsPermission()
                android.util.Log.d("AndroidSmsKitPlugin", "checkSmsPermission: $status")
                result.success(status)
            }
            "requestSmsPermission" -> {
                android.util.Log.d("AndroidSmsKitPlugin", "requestSmsPermission called")
                permissionResult = result
                requestSmsPermission()
            }
            "readSms" -> {
                android.util.Log.d("AndroidSmsKitPlugin", "readSms called")
                if (checkSmsPermission() == "granted") {
                    val messages = readSmsMessages()
                    result.success(messages)
                } else {
                    result.error("PERMISSION_DENIED", "SMS permission not granted", null)
                }
            }
            "getSimpleSms" -> {
                android.util.Log.d("AndroidSmsKitPlugin", "getSimpleSms called")
                if (checkSmsPermission() == "granted") {
                    val limit = call.argument<Int>("limit") ?: 100
                    val messages = getSimpleSms(limit)
                    result.success(messages)
                } else {
                    result.error("PERMISSION_DENIED", "SMS permission not granted", null)
                }
            }
            "getTransactionSms" -> {
                android.util.Log.d("AndroidSmsKitPlugin", "getTransactionSms called")
                if (checkSmsPermission() == "granted") {
                    val messages = readTransactionSms()
                    android.util.Log.d("AndroidSmsKitPlugin", "Returning ${messages.length} characters")
                    result.success(messages)
                } else {
                    android.util.Log.d("AndroidSmsKitPlugin", "Permission denied")
                    result.error("PERMISSION_DENIED", "SMS permission not granted", null)
                }
            }
            else -> {
                android.util.Log.d("AndroidSmsKitPlugin", "Method not implemented: ${call.method}")
                result.notImplemented()
            }
        }
    }

    private fun checkSmsPermission(): String {
        val currentActivity = activity ?: return "notDetermined"
        
        return when {
            ContextCompat.checkSelfPermission(
                currentActivity,
                Manifest.permission.READ_SMS
            ) == PackageManager.PERMISSION_GRANTED -> {
                "granted"
            }
            ActivityCompat.shouldShowRequestPermissionRationale(
                currentActivity,
                Manifest.permission.READ_SMS
            ) -> {
                "denied"
            }
            else -> {
                "notDetermined"
            }
        }
    }

    private fun requestSmsPermission() {
        val currentActivity = activity ?: run {
            permissionResult?.error("NO_ACTIVITY", "Activity not available", null)
            permissionResult = null
            return
        }
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            ActivityCompat.requestPermissions(
                currentActivity,
                arrayOf(Manifest.permission.READ_SMS),
                SMS_PERMISSION_CODE
            )
        } else {
            permissionResult?.success("granted")
            permissionResult = null
        }
    }

    private fun readSmsMessages(): String {
        val currentActivity = activity ?: return "[]"
        val smsUri = Uri.parse("content://sms/inbox")
        val projection = arrayOf("_id", "address", "body", "date", "type")
        val cursor: Cursor? = currentActivity.contentResolver.query(
            smsUri,
            projection,
            null,
            null,
            "date DESC LIMIT 100"
        )

        val jsonArray = JSONArray()

        cursor?.use {
            val addressIndex = it.getColumnIndex("address")
            val bodyIndex = it.getColumnIndex("body")
            val dateIndex = it.getColumnIndex("date")
            val typeIndex = it.getColumnIndex("type")

            while (it.moveToNext()) {
                val jsonObject = JSONObject()
                jsonObject.put("address", if (addressIndex >= 0) it.getString(addressIndex) else "")
                jsonObject.put("body", if (bodyIndex >= 0) it.getString(bodyIndex) else "")
                jsonObject.put("date", if (dateIndex >= 0) it.getLong(dateIndex) else 0)
                jsonObject.put("type", if (typeIndex >= 0) it.getInt(typeIndex) else 0)
                jsonArray.put(jsonObject)
            }
        }

        return jsonArray.toString()
    }

    private fun getSimpleSms(limit: Int): String {
        val currentActivity = activity ?: return "[]"
        val smsUri = Uri.parse("content://sms/inbox")
        val projection = arrayOf("address", "body", "date")
        val cursor: Cursor? = currentActivity.contentResolver.query(
            smsUri,
            projection,
            null,
            null,
            "date DESC LIMIT $limit"
        )

        val jsonArray = JSONArray()

        cursor?.use {
            val addressIndex = it.getColumnIndex("address")
            val bodyIndex = it.getColumnIndex("body")
            val dateIndex = it.getColumnIndex("date")

            while (it.moveToNext()) {
                val jsonObject = JSONObject()
                jsonObject.put("sender", if (addressIndex >= 0) it.getString(addressIndex) else "")
                jsonObject.put("message", if (bodyIndex >= 0) it.getString(bodyIndex) else "")
                jsonObject.put("timestamp", if (dateIndex >= 0) it.getLong(dateIndex) else 0)
                jsonArray.put(jsonObject)
            }
        }

        return jsonArray.toString()
    }

    private fun readTransactionSms(): String {
        val currentActivity = activity ?: return "[]"
        val smsUri = Uri.parse("content://sms/inbox")
        val projection = arrayOf("_id", "address", "body", "date", "type")
        val cursor: Cursor? = currentActivity.contentResolver.query(
            smsUri,
            projection,
            null,
            null,
            "date DESC LIMIT 500"
        )

        val jsonArray = JSONArray()

        cursor?.use {
            val addressIndex = it.getColumnIndex("address")
            val bodyIndex = it.getColumnIndex("body")
            val dateIndex = it.getColumnIndex("date")
            val typeIndex = it.getColumnIndex("type")

            while (it.moveToNext()) {
                val body = if (bodyIndex >= 0) it.getString(bodyIndex) else ""
                
                if (isTransactionSms(body)) {
                    val jsonObject = JSONObject()
                    jsonObject.put("address", if (addressIndex >= 0) it.getString(addressIndex) else "")
                    jsonObject.put("body", body)
                    jsonObject.put("date", if (dateIndex >= 0) it.getLong(dateIndex) else 0)
                    jsonObject.put("type", if (typeIndex >= 0) it.getInt(typeIndex) else 0)
                    jsonArray.put(jsonObject)
                }
            }
        }

        return jsonArray.toString()
    }

    private fun isTransactionSms(body: String): Boolean {
        if (body.isEmpty()) return false
        
        val lowerBody = body.lowercase()
        
        for (keyword in TRANSACTION_KEYWORDS) {
            if (lowerBody.contains(keyword)) {
                return true
            }
        }
        
        val amountPattern = Pattern.compile("(₹|rs\\.?|inr)\\s*\\d+", Pattern.CASE_INSENSITIVE)
        if (amountPattern.matcher(body).find()) {
            return true
        }
        
        return false
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray
    ): Boolean {
        if (requestCode == SMS_PERMISSION_CODE) {
            val granted = grantResults.isNotEmpty() && 
                         grantResults[0] == PackageManager.PERMISSION_GRANTED
            permissionResult?.success(if (granted) "granted" else "denied")
            permissionResult = null
            return true
        }
        return false
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}
