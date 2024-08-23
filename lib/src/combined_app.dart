import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'sample_bloc_feature/counter_page.dart';
import 'sample_bloc_feature/counter_bloc.dart';
import 'simplified_legacy_app.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';

class CombinedApp extends StatefulWidget {
  const CombinedApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  CombinedAppState createState() => CombinedAppState();
}

class CombinedAppState extends State<CombinedApp> {
  bool _isSampleItemAppActive = true; // Initially show the SampleItemApp

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          // Providing a restorationScopeId allows the Navigator built by the
          // MaterialApp to restore the navigation stack when a user leaves and
          // returns to the app after it has been killed while running in the
          // background.
          restorationScopeId: 'app',

          // Provide the generated AppLocalizations to the MaterialApp. This
          // allows descendant Widgets to display the correct translations
          // depending on the user's locale.
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],

          // Use AppLocalizations to configure the correct application title
          // depending on the user's locale.
          //
          // The appTitle is defined in .arb files found in the localization
          // directory.
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,

          // Define a light and dark color theme. Then, read the user's
          // preferred ThemeMode (light, dark, or system default) from the
          // SettingsController to display the correct theme.
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: widget.settingsController.themeMode,

          home: Scaffold(
            // Add a Scaffold to hold the app switcher and content
            appBar: AppBar(
              // title: Text(AppLocalizations.of(context)!.appTitle),
              title: const Text('Combined App'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    // Navigate to settings
                    Navigator.restorablePushNamed(
                        context, SettingsView.routeName);
                  },
                ),
              ],
            ),
            body: _isSampleItemAppActive
                ? const SampleItemApp()
                : BlocProvider(
                    create: (context) => CounterBloc(),
                    child: const CounterPage(),
                  ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _isSampleItemAppActive = !_isSampleItemAppActive;
                });
              },
              child: const Icon(Icons.swap_horiz),
            ),
          ),
        );
      },
    );
  }
}
