import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:navigation_launcher/navigation_launcher.dart';

import 'navigation_launcher_platform_interface.dart';

class MethodChannelNavigationLauncher extends NavigationLauncherPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('navigation_launcher');

  @override
  Future<List<MapApp>?> getInstalledMaps() async {
    var result = await methodChannel.invokeMethod('getInstalledMaps');
    if (result is! List) return null;
    return result
        .map((name) => MapApp.values.firstWhere((e) => e.name == name))
        .toList();
  }

  @override
  Future launchNavigation(MapApp app, LatLng latLng, String name) async {
    await methodChannel.invokeMethod('launchNavigation', {
      'app': app.name,
      'point': [latLng.longitude, latLng.latitude],
      'name': name,
    });
  }
}
