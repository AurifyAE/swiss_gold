package com.aurify.swissgold

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            Log.d("BootReceiver", "Boot completed - device restarted")
            // Add any logic you need to run on device boot
            // For example, reschedule alarms or notifications
        }
    }
}