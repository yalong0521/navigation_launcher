package com.whale.navigation_launcher

import android.content.Context
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class NavigationLauncherPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "navigation_launcher")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "getInstalledMaps") {
            val list = arrayListOf<String>()
            for (value in MapApp.values()) {
                if (isInstalled(value.id)) list.add(value.value)
            }
            result.success(list)
        } else if (call.method == "launchNavigation") {
             val app = MapApp.values().firstOrNull {
                it.value == call.argument<String>("app")
            }
            if (app == null) {
                result.error("unknown_app", "不支持的地图", null)
            } else if (!isInstalled(app.id)) {
                result.error(app.value, "未安装${app.desc}地图", null)
            } else {
                val point = call.argument<List<Double>>("point")
                val name = call.argument<String>("name")
                when (app) {
                    MapApp.GAODE -> navigateGaode(point!![0], point[1], name)
                    MapApp.BAIDU -> navigateBaidu(point!![0], point[1])
                    MapApp.TENCENT -> navigateTencent(point!![0], point[1], name)
                    MapApp.GOOGLE -> navigateGoogle(point!![0], point[1])
                }
                result.success(true)
            }
        } else {
            result.notImplemented()
        }
    }

    private fun navigateGaode(lon: Double, lat: Double, name: String?) {
        Intent().apply {
            action = Intent.ACTION_VIEW
            val param = "dlat=${lat}&dlon=${lon}&dname=${name}&dev=1&t=0"
            data = Uri.parse("amapuri://route/plan/?$param")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(this)
        }
    }

    private fun navigateBaidu(lon: Double, lat: Double) {
        Intent().apply {
            action = Intent.ACTION_VIEW
            val param =
                "destination=${lat},${lon}&coord_type=wgs84&mode=driving&src=${context.packageName}"
            data = Uri.parse("baidumap://map/direction?$param")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(this)
        }
    }

    private fun navigateTencent(lon: Double, lat: Double, name: String?) {
        Intent().apply {
            action = Intent.ACTION_VIEW
            val param = "type=drive&fromcoord=CurrentLocation&to=${name}&tocoord=${lat},${lon}"
            data = Uri.parse("qqmap://map/routeplan?$param")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(this)
        }
    }

    private fun navigateGoogle(lon: Double, lat: Double) {
        Intent().apply {
            action = Intent.ACTION_VIEW
            val param = "q=${lat},${lon}"
            data = Uri.parse("google.navigation:$param")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            setPackage(MapApp.GOOGLE.id)
            context.startActivity(this)
        }
    }

    @Suppress("DEPRECATION")
    private fun isInstalled(id: String): Boolean {
        val packages = context.packageManager.getInstalledPackages(0)
        for (p in packages) {
            if (p.packageName.equals(id)) return true else continue
        }
        return false
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    enum class MapApp(val value: String, val id: String, val desc: String) {
        GAODE("gaode", "com.autonavi.minimap", "高德"),
        BAIDU("baidu", "com.baidu.BaiduMap", "百度"),
        TENCENT("tencent", "com.tencent.map", "腾讯"),
        GOOGLE("google", "com.google.android.apps.maps", "谷歌");
    }
}
