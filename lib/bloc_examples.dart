import 'package:flutter/material.dart';

import 'src/legacy_app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart'; // Import for debounce

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() {
    emit(state + 1);
  }
}

class DoublerCubit extends Cubit<int> {
  DoublerCubit() : super(0);

  void increment() {
    emit(state + 2);
  }
}

class SimpleBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('${bloc.runtimeType} $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('${bloc.runtimeType} $error $stackTrace');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print('${bloc.runtimeType} $transition');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    print('${bloc.runtimeType} $event');
  }
}

void main() async {
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(MyApp(settingsController: settingsController));

  // BLoC experiments below

  Bloc.observer = SimpleBlocObserver();

  example_cubit:
  {
    CounterCubit()
      ..increment()
      ..increment()
      ..increment()
      ..close();

    DoublerCubit()
      ..increment()
      ..increment()
      ..increment()
      ..close();
  }

  example_bloc:
  {
    // this counter will be debounced
    CounterBloc()
      ..add(CounterIncrementPressed())
      ..add(CounterIncrementPressed())
      ..add(CounterIncrementPressed())
      ..close();
  }

  example_stream:
  {
    // final bloc = DoublerBloc();
    // final subscription =
    //     bloc.stream.listen((it) => print('streamListener> $it'));
    // bloc.add(CounterIncrementPressed());
    // bloc.add(CounterIncrementPressed());
    // bloc.add(CounterIncrementPressed());
    // await Future.delayed(Duration.zero);
    // await subscription.cancel();
    // await bloc.close();

    DoublerBloc()
      ..add(CounterIncrementPressed())
      ..add(CounterIncrementPressed())
      ..add(CounterIncrementPressed())
      ..close();
  }

  example_sidestep_debounce_with_delays:
  {
    final bloc = CounterBloc();
    bloc.add(CounterIncrementPressed());
    await Future.delayed(const Duration(milliseconds: 301));
    bloc.add(CounterIncrementPressed());
    await Future.delayed(const Duration(milliseconds: 301));
    bloc.add(CounterIncrementPressed());
    await bloc.close();
  }
}

sealed class CounterEvent {}

final class CounterIncrementPressed extends CounterEvent {}

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<CounterIncrementPressed>(
      (event, emit) => emit(state + 1),
      transformer: debounce(const Duration(milliseconds: 300)),
    );
  }

  // Stream<int> mapEventToState(CounterEvent event) async* {
  //   if (event is CounterIncrementPressed) {
  //     yield state + 1;
  //   }
  // }

  EventTransformer<T> debounce<T>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
  }
}

class DoublerBloc extends Bloc<CounterEvent, int> {
  DoublerBloc() : super(0) {
    on<CounterIncrementPressed>((event, emit) {
      emit(state + 2);
    });
  }
}
