import 'package:coordtransform_dart/coordtransform_dart.dart';
import 'package:latlong2/latlong.dart';

import 'navigation_launcher_platform_interface.dart';

export 'package:latlong2/latlong.dart';

class NavigationLauncher {
  Future<List<MapApp>?> getInstalledMaps() {
    return NavigationLauncherPlatform.instance.getInstalledMaps();
  }

  /// [app] reference [MapApp]
  /// [latLng] destination coordinate -> WGS84
  /// [name] destination name
  Future launchNavigation(MapApp app, LatLng latLng, {String name = '终点'}) {
    if (app == MapApp.tencent) {
      var gcj02 = CoordinateTransformUtil.wgs84ToGcj02(
          latLng.longitude, latLng.latitude);
      latLng = LatLng(gcj02[1], gcj02[0]);
    }
    return NavigationLauncherPlatform.instance
        .launchNavigation(app, latLng, name);
  }
}

enum MapApp {
  gaode('高德地图'),
  baidu('百度地图'),
  tencent('腾讯地图'),
  google('谷歌地图'),
  apple('苹果地图');

  final String desc;

  const MapApp(this.desc);
}
