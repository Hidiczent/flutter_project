/// Lao Epic mobile app entry point.
library;

import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/app/app_providers.dart';
import 'package:laoepic_thesis_app/app/bootstrap.dart';
import 'package:laoepic_thesis_app/app/lao_epic_app.dart';
import 'package:provider/provider.dart';

/// Initializes services and launches the root widget tree.

Future<void> main() async {
  final uiI18n = await AppBootstrap.initialize();

  runApp(
    MultiProvider(
      providers: buildAppProviders(uiI18n),
      child: const LaoEpicApp(),
    ),
  );
}
