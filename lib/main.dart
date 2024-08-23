import 'package:flutter/material.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

// for running only existing non-bloc app
// import 'src/legacy_app.dart';

// for running only bloc
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'src/sample_bloc_feature/counter_bloc.dart';
// import 'src/sample_bloc_feature/counter_page.dart';

// for running both
// import 'src/homepage.dart';
// import 'src/legacy_app.dart';

// for running combined app
import 'src/combined_app.dart';

void main() async {
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // // Run the app and pass in the SettingsController. The app listens to the
  // // SettingsController for changes, then passes it further down to the
  // // SettingsView.
  // runApp(MyApp(settingsController: settingsController));

  // // run only new bloc app
  // runApp(
  //   MaterialApp(
  //     // Wrap your app with MaterialApp
  //     home: BlocProvider(
  //       // Provide the CounterBloc at the root
  //       create: (_) => CounterBloc(),
  //       child: const CounterPage(),
  //     ),
  //   ),
  // );

  // // run both apps, with an app switcher
  // runApp(
  //   MaterialApp(
  //     home: HomePage(
  //       legacyApp: MyApp(settingsController: settingsController),
  //     ),
  //   ),
  // );

  // new combined app
  runApp(CombinedApp(settingsController: settingsController));
}
