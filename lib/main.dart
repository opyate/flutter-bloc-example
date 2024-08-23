import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

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

  cubit_example:
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

  bloc_example:
  {
    // final bloc = CounterBloc();
    // // print(bloc.state); // 0
    // bloc.add(CounterIncrementPressed());
    // // await Future.delayed(Duration.zero);
    // // print(bloc.state); // 1
    // bloc.add(CounterIncrementPressed());
    // bloc.add(CounterIncrementPressed());
    // await bloc.close();

    CounterBloc()
      ..add(CounterIncrementPressed())
      ..add(CounterIncrementPressed())
      ..add(CounterIncrementPressed())
      ..close();
  }

  stream_example:
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
}

sealed class CounterEvent {}

final class CounterIncrementPressed extends CounterEvent {}

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<CounterIncrementPressed>((event, emit) {
      emit(state + 1);
    });
  }

  // @override
  // void onChange(Change<int> change) {
  //   super.onChange(change);
  //   print(change);
  // }

  // Stream<int> mapEventToState(CounterEvent event) async* {
  //   if (event is CounterIncrementPressed) {
  //     yield state + 1;
  //   }
  // }

  // @override
  // void onTransition(Transition<CounterEvent, int> transition) {
  //   super.onTransition(transition);
  //   print(transition);
  // }
}

class DoublerBloc extends Bloc<CounterEvent, int> {
  DoublerBloc() : super(0) {
    on<CounterIncrementPressed>((event, emit) {
      emit(state + 2);
    });
  }

  // @override
  // void onChange(Change<int> change) {
  //   super.onChange(change);
  //   print(change);
  // }

  // @override
  // void onTransition(Transition<CounterEvent, int> transition) {
  //   super.onTransition(transition);
  //   print(transition);
  // }
}
