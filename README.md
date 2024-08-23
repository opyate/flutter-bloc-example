# flutter_default_skeleton_project

Converting the default Flutter skeleton project to a BLoC-powered app.

# Learnings

## BLoC

- BLoC's Cubits remind me of Riverpod (see [Note 1](#note-1)) in that it simplifies state management via direct state mutation via methods, with less boilerplate
- Cubit's bigger sibling is Bloc, but instead of calling functions to mutate state, Bloc receives incoming events, which it converts into outgoing states via your business logic
- Cubit and Bloc state changes can be centrally observed via a BlocObserver by setting Bloc.observer
- Cubit and Bloc both extend BlocBase (which is the base type the BlocObserver accepts in its handlers)
- Bloc advantages (see [versus](https://bloclibrary.dev/bloc-concepts/#cubit-vs-bloc)):
    - event-driven approach lends itself to more traceability
    - event transformations (e.g. buffer, debounce, etc)
    - benefit from reactive extensions (e.g. `rxdart` (see [Note 3](#note-3)))
- Cubit outputs are serial, whereas Bloc output is interleaved (see [Note 2](#note-2))  and this is due to the async nature of event streams

## Flutter BLoC

TODO

# Notes

## Note 1

Riverpod is what [Andrea](https://codewithandrea.com/) used in our receipt scanner project for DunnHumby; I had the mobile app checked out and running on my computer too and sent a few PRs; likewise, Andrea learned about Firebase from me and incorporated it into his courses.

## Note 2

Calling this code:

```
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

CounterBloc()
    ..add(CounterIncrementPressed())
    ..add(CounterIncrementPressed())
    ..add(CounterIncrementPressed())
    ..close();

DoublerBloc()
      ..add(CounterIncrementPressed())
      ..add(CounterIncrementPressed())
      ..add(CounterIncrementPressed())
      ..close();
```

Showed this output (note how the Bloc output is interleaved):

```
I/flutter ( 3445): CounterCubit Change { currentState: 0, xtState: 1 }
I/flutter ( 3445): CounterCubit Change { currentState: 1, xtState: 2 }
I/flutter ( 3445): CounterCubit Change { currentState: 2, xtState: 3 }
I/flutter ( 3445): DoublerCubit Change { currentState: 0, xtState: 2 }
I/flutter ( 3445): DoublerCubit Change { currentState: 2, xtState: 4 }
I/flutter ( 3445): DoublerCubit Change { currentState: 4, xtState: 6 }
I/flutter ( 3445): CounterBloc Change { currentState: 0, xtState: 1 }
I/flutter ( 3445): DoublerBloc Change { currentState: 0, xtState: 2 }
I/flutter ( 3445): CounterBloc Change { currentState: 1, xtState: 2 }
I/flutter ( 3445): DoublerBloc Change { currentState: 2, xtState: 4 }
I/flutter ( 3445): CounterBloc Change { currentState: 2, xtState: 3 }
I/flutter ( 3445): DoublerBloc Change { currentState: 4, nextState: 6 }
```

The `onEvent` outputs will be in quick succession, though, and the local `onEvent` is invoked before the global `onEvent` in BlocObserver.

```
(3) I/flutter ( 3445): CounterBloc Instance of 'CounterIncrementPressed'
(3) I/flutter ( 3445): DoublerBloc Instance of 'CounterIncrementPressed'
```

Explanation:

Bloc: Built on top of streams, Blocs process events asynchronously. When you add multiple events in quick succession using the cascade operator (`..`), they are added to the Bloc's event queue. The Bloc then processes these events one by one, potentially leading to interleaved state updates if the processing of one event takes longer than the arrival of subsequent events.

Cubit: While also capable of handling asynchronous operations, Cubits are designed to be simpler and more synchronous in nature. They directly mutate their state in response to method calls. When you use the cascade operator with a Cubit, the method calls are executed sequentially, resulting in serial state updates.

## Note 3

I have extensive RxJava experience from my Java days, so the knowledge/experience will transfer nicely.

