package com.example.ai_bot

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.net.wifi.WifiManager
import android.net.wifi.WifiConfiguration
import android.net.wifi.WifiNetworkSpecifier
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkRequest
import android.net.NetworkCapabilities
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi
import java.math.BigInteger
import java.net.InetAddress
import java.nio.ByteOrder

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.ai_bot/wifi_provision"
    private var wifiManager: WifiManager? = null
    private var connectivityManager: ConnectivityManager? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // 初始化WiFi管理器
        wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        connectivityManager = applicationContext.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "connectToWiFi" -> {
                    val ssid = call.argument<String>("ssid")
                    val password = call.argument<String>("password")
                    
                    if (ssid == null) {
                        result.error("INVALID_ARGUMENTS", "SSID cannot be null", null)
                        return@setMethodCallHandler
                    }
                    
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        connectToWiFiAndroid10Plus(ssid, password ?: "", result)
                    } else {
                        connectToWiFiLegacy(ssid, password ?: "", result)
                    }
                }
                "getGatewayIp" -> {
                    result.success(getGatewayIp())
                }
                "isWifiSaved" -> {
                    val ssid = call.argument<String>("ssid")
                    if (ssid == null) {
                        result.error("INVALID_ARGUMENTS", "SSID cannot be null", null)
                        return@setMethodCallHandler
                    }
                    result.success(isWifiSaved(ssid))
                }
                "connectToSavedWifi" -> {
                    val ssid = call.argument<String>("ssid")
                    if (ssid == null) {
                        result.error("INVALID_ARGUMENTS", "SSID cannot be null", null)
                        return@setMethodCallHandler
                    }
                    connectToSavedWifi(ssid, result)
                }
                "getCurrentWifiSSID" -> {
                    result.success(getCurrentWifiSSID())
                }
                "getSavedWifiList" -> {
                    result.success(getSavedWifiList())
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    // 获取网关IP地址
    private fun getGatewayIp(): String? {
        if (wifiManager == null) {
            Log.e("WiFiProvision", "WiFi管理器未初始化")
            return null
        }
        
        try {
            val dhcpInfo = wifiManager!!.dhcpInfo
            if (dhcpInfo != null) {
                // Android提供的网关IP是小端字节序的整数，需要转换
                var gatewayIp = dhcpInfo.gateway
                if (ByteOrder.nativeOrder() == ByteOrder.LITTLE_ENDIAN) {
                    gatewayIp = Integer.reverseBytes(gatewayIp)
                }
                
                val ipAddress = InetAddress.getByAddress(BigInteger.valueOf(gatewayIp.toLong()).toByteArray())
                return ipAddress.hostAddress
            }
        } catch (e: Exception) {
            Log.e("WiFiProvision", "获取网关IP出错: ${e.message}")
        }
        
        // 如果无法获取网关地址，返回常见ESP设备地址
        return "192.168.4.1"
    }

    // Android 10+的WiFi连接方法
    @RequiresApi(Build.VERSION_CODES.Q)
    private fun connectToWiFiAndroid10Plus(ssid: String, password: String, result: MethodChannel.Result) {
        try {
            Log.d("WiFiProvision", "使用Android 10+方法连接到WiFi: $ssid")
            
            val specifier = WifiNetworkSpecifier.Builder()
                .setSsid(ssid)
                .setWpa2Passphrase(password)
                .build()

            val request = NetworkRequest.Builder()
                .addTransportType(NetworkCapabilities.TRANSPORT_WIFI)
                .setNetworkSpecifier(specifier)
                .build()

            val networkCallback = object : ConnectivityManager.NetworkCallback() {
                override fun onAvailable(network: Network) {
                    super.onAvailable(network)
                    // 强制使用此网络连接
                    connectivityManager?.bindProcessToNetwork(network)
                    
                    activity.runOnUiThread {
                        Log.d("WiFiProvision", "WiFi连接成功: $ssid")
                        result.success(true)
                    }
                }

                override fun onUnavailable() {
                    super.onUnavailable()
                    activity.runOnUiThread {
                        Log.e("WiFiProvision", "WiFi连接失败: $ssid")
                        result.success(false)
                    }
                }
            }

            connectivityManager?.requestNetwork(request, networkCallback)
        } catch (e: Exception) {
            Log.e("WiFiProvision", "WiFi连接出错: ${e.message}")
            result.error("CONNECTION_ERROR", "Failed to connect: ${e.message}", null)
        }
    }

    // 旧版Android WiFi连接方法
    private fun connectToWiFiLegacy(ssid: String, password: String, result: MethodChannel.Result) {
        try {
            Log.d("WiFiProvision", "使用旧版方法连接到WiFi: $ssid")
            
            val conf = WifiConfiguration()
            conf.SSID = "\"$ssid\"" // 需要加上引号
            
            if (password.isEmpty()) {
                conf.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.NONE)
            } else {
                conf.preSharedKey = "\"$password\""
            }
            
            val networkId = wifiManager?.addNetwork(conf)
            if (networkId != null && networkId != -1) {
                wifiManager?.disconnect()
                wifiManager?.enableNetwork(networkId, true)
                val success = wifiManager?.reconnect() ?: false
                
                if (success) {
                    Log.d("WiFiProvision", "WiFi连接中: $ssid")
                    result.success(true)
                } else {
                    Log.e("WiFiProvision", "WiFi连接失败: $ssid")
                    result.success(false)
                }
            } else {
                Log.e("WiFiProvision", "添加网络配置失败: $ssid")
                result.success(false)
            }
        } catch (e: Exception) {
            Log.e("WiFiProvision", "WiFi连接出错: ${e.message}")
            result.error("CONNECTION_ERROR", "Failed to connect: ${e.message}", null)
        }
    }

    // 检查WiFi是否已保存
    private fun isWifiSaved(ssid: String): Boolean {
        if (wifiManager == null) {
            Log.e("WiFiProvision", "WiFi管理器未初始化")
            return false
        }
        
        try {
            // 获取已配置的网络列表
            val configuredNetworks = wifiManager!!.configuredNetworks
            if (configuredNetworks != null) {
                for (network in configuredNetworks) {
                    // 移除SSID中的引号进行比较
                    val networkSsid = network.SSID.replace("\"", "")
                    if (networkSsid == ssid) {
                        Log.d("WiFiProvision", "找到已保存的WiFi: $ssid")
                        return true
                    }
                }
            }
        } catch (e: Exception) {
            Log.e("WiFiProvision", "检查已保存WiFi时出错: ${e.message}")
        }
        
        return false
    }
    
    // 连接到已保存的WiFi
    private fun connectToSavedWifi(ssid: String, result: MethodChannel.Result) {
        if (wifiManager == null) {
            Log.e("WiFiProvision", "WiFi管理器未初始化")
            result.success(false)
            return
        }
        
        try {
            // 获取已配置的网络列表
            val configuredNetworks = wifiManager!!.configuredNetworks
            if (configuredNetworks != null) {
                for (network in configuredNetworks) {
                    // 移除SSID中的引号进行比较
                    val networkSsid = network.SSID.replace("\"", "")
                    if (networkSsid == ssid) {
                        // 找到匹配的网络，尝试连接
                        wifiManager!!.disconnect()
                        val enableResult = wifiManager!!.enableNetwork(network.networkId, true)
                        val reconnectResult = wifiManager!!.reconnect()
                        
                        Log.d("WiFiProvision", "连接到已保存的WiFi: $ssid, 启用结果: $enableResult, 重连结果: $reconnectResult")
                        
                        // 返回结果
                        result.success(enableResult && reconnectResult)
                        return
                    }
                }
            }
            
            // 未找到匹配的网络
            Log.d("WiFiProvision", "未找到已保存的WiFi: $ssid")
            result.success(false)
        } catch (e: Exception) {
            Log.e("WiFiProvision", "连接已保存WiFi时出错: ${e.message}")
            result.success(false)
        }
    }

    // 获取当前连接的WiFi SSID
    private fun getCurrentWifiSSID(): String? {
        if (wifiManager == null) {
            Log.e("WiFiProvision", "WiFi管理器未初始化")
            return null
        }
        
        try {
            val connectionInfo = wifiManager!!.connectionInfo
            if (connectionInfo != null) {
                var ssid = connectionInfo.ssid
                // 移除SSID中的引号
                if (ssid.startsWith("\"") && ssid.endsWith("\"")) {
                    ssid = ssid.substring(1, ssid.length - 1)
                }
                Log.d("WiFiProvision", "当前连接的WiFi: $ssid")
                return ssid
            }
        } catch (e: Exception) {
            Log.e("WiFiProvision", "获取当前WiFi SSID出错: ${e.message}")
        }
        
        return null
    }

    // 获取已保存的WiFi列表
    private fun getSavedWifiList(): List<String> {
        if (wifiManager == null) {
            Log.e("WiFiProvision", "WiFi管理器未初始化")
            return emptyList()
        }
        
        val savedNetworks = mutableListOf<String>()
        
        try {
            // 获取已配置的网络列表
            val configuredNetworks = wifiManager!!.configuredNetworks
            if (configuredNetworks != null) {
                for (network in configuredNetworks) {
                    // 移除SSID中的引号
                    var ssid = network.SSID
                    if (ssid.startsWith("\"") && ssid.endsWith("\"")) {
                        ssid = ssid.substring(1, ssid.length - 1)
                    }
                    
                    if (ssid.isNotEmpty()) {
                        savedNetworks.add(ssid)
                    }
                }
            }
            
            Log.d("WiFiProvision", "已保存的WiFi列表: $savedNetworks")
        } catch (e: Exception) {
            Log.e("WiFiProvision", "获取已保存WiFi列表出错: ${e.message}")
        }
        
        return savedNetworks
    }
}
