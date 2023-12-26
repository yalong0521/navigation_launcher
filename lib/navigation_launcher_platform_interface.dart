import 'package:latlong2/latlong.dart';
import 'package:navigation_launcher/navigation_launcher.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'navigation_launcher_method_channel.dart';

abstract class NavigationLauncherPlatform extends PlatformInterface {
  NavigationLauncherPlatform() : super(token: _token);

  static final Object _token = Object();

  static NavigationLauncherPlatform _instance =
      MethodChannelNavigationLauncher();

  static NavigationLauncherPlatform get instance => _instance;

  static set instance(NavigationLauncherPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<List<MapApp>?> getInstalledMaps() {
    throw UnimplementedError('getInstalledMaps() has not been implemented.');
  }

  Future launchNavigation(MapApp app, LatLng latLng, String name) {
    throw UnimplementedError('launchNavigation() has not been implemented.');
  }
}
