package com.example.riderescue_services

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class ActionBroadcastReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        Log.d("ActionBroadcastReceiver", "Action broadcast received: ${intent.action}")
        
        // Here you can handle different notification actions
        // Example: Handle notification button clicks or actions
        
        when (intent.action) {
            "ACCEPT_BOOKING" -> {
                // Handle accept booking action
                Log.d("ActionBroadcastReceiver", "Accept booking action")
            }
            "DECLINE_BOOKING" -> {
                // Handle decline booking action
                Log.d("ActionBroadcastReceiver", "Decline booking action")
            }
            else -> {
                Log.d("ActionBroadcastReceiver", "Unknown action: ${intent.action}")
            }
        }
    }
} 