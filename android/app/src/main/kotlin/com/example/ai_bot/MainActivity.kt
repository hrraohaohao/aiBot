package com.example.ai_bot

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import androidx.multidex.MultiDex
import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.net.wifi.WifiManager
import android.net.wifi.WifiNetworkSpecifier
import android.net.wifi.WifiConfiguration
import android.net.NetworkRequest
import android.net.ConnectivityManager
import android.net.Network
import android.os.Build
import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import android.content.Intent
import android.provider.Settings

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.ai_bot/wifi"
    private lateinit var wifiManager: WifiManager
    private lateinit var connectivityManager: ConnectivityManager
    
    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
        MultiDex.install(this)
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        connectivityManager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // 注册方法通道
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "connectToWifi" -> {
                    val ssid = call.argument<String>("ssid") ?: ""
                    connectToWifi(ssid, result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    private fun connectToWifi(ssid: String, result: MethodChannel.Result) {
        Log.d("WiFiConnect", "尝试连接到WiFi: $ssid")
        
        // 确保WiFi已启用
        if (!wifiManager.isWifiEnabled) {
            wifiManager.isWifiEnabled = true
        }
        
        // 使用不同的API根据Android版本连接WiFi
        GlobalScope.launch(Dispatchers.Main) {
            try {
                val connected = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    // Android 10及以上使用新API
                    connectAndroid10OrAbove(ssid)
                } else {
                    // Android 9及以下使用旧API
                    connectAndroid9OrBelow(ssid)
                }
                
                result.success(connected)
            } catch (e: Exception) {
                Log.e("WiFiConnect", "连接WiFi失败: ${e.message}")
                result.success(false)
            }
        }
    }
    
    // Android 10及以上使用新API连接WiFi
    private fun connectAndroid10OrAbove(ssid: String): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) return false
        
        try {
            // 通常设备热点不需要密码，这里假设是开放网络
            val specifier = WifiNetworkSpecifier.Builder()
                .setSsid(ssid)
                .build()
            
            val request = NetworkRequest.Builder()
                .addTransportType(android.net.NetworkCapabilities.TRANSPORT_WIFI)
                .setNetworkSpecifier(specifier)
                .build()
            
            // 弹出系统选择WiFi的界面
            val intent = Intent(Settings.Panel.ACTION_WIFI)
            startActivity(intent)
            
            // 注意：这种情况下我们无法准确知道是否连接成功
            // 因为用户需要在系统界面上操作
            return true
        } catch (e: Exception) {
            Log.e("WiFiConnect", "Android 10+连接失败: ${e.message}")
            return false
        }
    }
    
    // Android 9及以下使用旧API连接WiFi
    @Suppress("DEPRECATION")
    private fun connectAndroid9OrBelow(ssid: String): Boolean {
        try {
            // 配置WiFi连接参数
            val conf = WifiConfiguration()
            conf.SSID = "\"$ssid\"" // 需要加双引号
            conf.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.NONE) // 开放网络
            
            // 添加网络配置
            val netId = wifiManager.addNetwork(conf)
            if (netId == -1) {
                Log.e("WiFiConnect", "添加网络配置失败")
                return false
            }
            
            // 断开当前连接并连接到新网络
            wifiManager.disconnect()
            val success = wifiManager.enableNetwork(netId, true)
            wifiManager.reconnect()
            
            return success
        } catch (e: Exception) {
            Log.e("WiFiConnect", "Android 9-连接失败: ${e.message}")
            return false
        }
    }
}
