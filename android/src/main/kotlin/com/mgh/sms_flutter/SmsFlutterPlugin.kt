package com.mgh.sms_flutter

import android.Manifest
import android.annotation.SuppressLint
import android.content.*
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.Settings
import android.telephony.SmsManager
import android.telephony.SubscriptionInfo
import android.telephony.SubscriptionManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import android.provider.Telephony
import android.content.BroadcastReceiver
import android.content.Context
import android.content.IntentFilter
import androidx.annotation.NonNull










class SmsFlutterPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
  private lateinit var channel: MethodChannel
  private var context: Context? = null
  private var activity: android.app.Activity? = null
  private val REQUEST_CODE_SMS = 100
  private var pendingResult: MethodChannel.Result? = null

  private val requiredPermissions = arrayOf(
    Manifest.permission.SEND_SMS,
    Manifest.permission.RECEIVE_SMS,
    Manifest.permission.READ_PHONE_STATE
  )

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    context = binding.applicationContext
    channel = MethodChannel(binding.binaryMessenger, "sms.receiver.channel")
    channel.setMethodCallHandler(this)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    binding.addRequestPermissionsResultListener { requestCode, permissions, grantResults ->
      if (requestCode == REQUEST_CODE_SMS) {
        val allGranted = grantResults.all { it == PackageManager.PERMISSION_GRANTED }
        if (allGranted) {
          pendingResult?.let {
            registerSmsReceiver(it)
            pendingResult = null
          }
        } else {

          openAppSettings()
          pendingResult?.error("PERMISSION_DENIED", "permission DENIED", null)
          pendingResult = null
        }
        true
      } else {
        false
      }
    }
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    when (call.method) {
      "get_sim_count" -> {
        if (checkAndRequestPermissions()) {
          val simCount = getSimCount()
          result.success(simCount)
        } else {
          result.error("PERMISSION_DENIED", "permission DENIED", null)
        }
      }
      "send_sms_with_sim" -> {
        val phoneNumberUser = call.argument<String>("phone_number")
        val message = call.argument<String>("message")
        val simSlot = call.argument<Int>("sim_slot") ?: 0

        if (checkAndRequestPermissions()) {
          sendSmsFromSim(phoneNumberUser, message, simSlot)

          result.success("پیام ارسال شد با سیم $simSlot")
        } else {
          result.error("PERMISSION_DENIED", "مجوزها داده نشده‌اند", null)
        }
      }
      "receive_sms" -> {
        if (checkAndRequestPermissions()) {
          registerSmsReceiver(result)
        } else {
          pendingResult = result
        }
      }
      "check_permissions" -> {
        val permissionsGranted = checkPermissions()
        result.success(permissionsGranted)
      }
      "request_permissions" -> {
        requestPermissions()
        result.success(null)
      }
      else -> result.notImplemented()
    }
  }

  private fun checkAndRequestPermissions(): Boolean {
    val permissionsNeeded = requiredPermissions.filter {
      ContextCompat.checkSelfPermission(context!!, it) != PackageManager.PERMISSION_GRANTED
    }

    return if (permissionsNeeded.isEmpty()) {
      true
    } else {
      ActivityCompat.requestPermissions(activity!!, permissionsNeeded.toTypedArray(), REQUEST_CODE_SMS)
      false
    }
  }


  private fun checkPermissions(): Boolean {
    return requiredPermissions.all {
      ContextCompat.checkSelfPermission(context!!, it) == PackageManager.PERMISSION_GRANTED
    }
  }


  private fun requestPermissions() {
    ActivityCompat.requestPermissions(activity!!, requiredPermissions, REQUEST_CODE_SMS)
  }

  private fun openAppSettings() {
    val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
    intent.data = Uri.parse("package:${context!!.packageName}")
    activity?.startActivity(intent)
  }

  private fun registerSmsReceiver(result: MethodChannel.Result) {
    val smsReceiver = object : BroadcastReceiver() {
      override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
          val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
          if (messages.isNotEmpty()) {
            val senderNumber = messages[0].displayOriginatingAddress
            val messageBodyBuilder = StringBuilder()
            for (sms in messages) {
              messageBodyBuilder.append(sms.messageBody)
            }
            val fullMessage = messageBodyBuilder.toString()

            val dataMap = mapOf(
              "sender" to senderNumber,
              "message" to fullMessage
            )

            result.success(dataMap)
            context?.unregisterReceiver(this)
          }
        }
      }
    }

    val filter = IntentFilter(Telephony.Sms.Intents.SMS_RECEIVED_ACTION)
    context?.registerReceiver(smsReceiver, filter)
  }

  @SuppressLint("MissingPermission")
  private fun getSimCount(): Int {
    val subscriptionManager = context!!.getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as SubscriptionManager
    val activeSubscriptionInfoList: List<SubscriptionInfo>? = subscriptionManager.activeSubscriptionInfoList
    return activeSubscriptionInfoList?.size ?: 0
  }

  @SuppressLint("NewApi")
  fun sendSmsFromSim(phoneNumber: String?, message: String?, simSlot: Int) {
    CoroutineScope(Dispatchers.IO).launch {
      try {
        val subscriptionManager = context?.getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as SubscriptionManager
        val subscriptionInfoList = subscriptionManager.activeSubscriptionInfoList

        if (subscriptionInfoList != null && simSlot < subscriptionInfoList.size) {
          val subscriptionId = subscriptionInfoList[simSlot].subscriptionId
          val smsManager = SmsManager.getSmsManagerForSubscriptionId(subscriptionId)

          smsManager.sendTextMessage(phoneNumber, null, message, null, null)

        } else {


        }
      } catch (e: Exception) {
        e.printStackTrace()


      }
    }
  }
}
