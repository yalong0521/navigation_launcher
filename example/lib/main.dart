import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:navigation_launcher/navigation_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<MapApp>? _maps;
  final _navigationLauncherPlugin = NavigationLauncher();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    List<MapApp>? maps;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      maps = await _navigationLauncherPlugin.getInstalledMaps();
    } on PlatformException {
      maps = [];
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _maps = maps;
    });
  }

  @override
  Widget build(BuildContext context) {
    final maps = _maps;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: maps == null
            ? null
            : Center(
                child: ListView.builder(
                  itemBuilder: (context, index) => ListTile(
                    title: Text(maps[index].name),
                    onTap: () {
                      _navigationLauncherPlugin.launchNavigation(
                        maps[index],
                        const LatLng(39.4, 115.7),
                        name: '北京',
                      );
                    },
                  ),
                  itemCount: maps.length,
                ),
              ),
      ),
    );
  }
}
