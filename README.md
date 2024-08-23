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

- `BlocBuilder` (simple), `StreamBuilder` (more advanced)
    - subscribes to the stream of states emitted by the specified BLoC/Cubit 
    - can optionally be provided a bloc via method `bloc`, or alternatively it will look for an instance of the specified type in the widget tree using `context.read`
    - method `builder` takes the BuildContext and the current state as input and returns the widgets to be built based on the state
    - Whenever the BLoC/Cubit emits a new state, BlocBuilder rebuilds its child widget(s) using the latest state (or conditionally via `buildWhen`)
    - only rebuilds the widgets within its subtree that depend on the changed state, improving performance
    - should be a pure function (idempotent, no side-effects), as it might be called many times
    - typically used within the widget tree of a `BlocProvider`, which provides the BLoC/Cubit instance to its descendants
    - If you need to perform side effects (e.g., showing a dialog) in response to state changes, consider using `BlocListener` in conjunction with `BlocBuilder`.
- `BlocSelector`
    - like a "filtered BlocBuilder"
    - extra method `selector` which returns *selected* (immutable) state based on the provided state
    - Unnecessary builds are prevented if the *selected* state does not change
- `BlocProvider` (or `MultiBlocProvider` for merging multiple `BlocProvider`, and eliminate need for nesting multiple `BlocProvider`)
    - provides a bloc to its tree of children via `BlocProvider.of<T>(context)`
    - dependency injection (DI) widget so that a single instance of a bloc can be provided to multiple widgets within a subtree
    - Use `create` to create new Blocs/Cubits that are automatically closed.
    - Use `value` to provide existing Blocs/Cubits, but manage their lifecycle manually.
    - Be mindful of nested BlocProviders and how they interact.
    - Consider using state management solutions like RepositoryProvider to manage dependencies other than Blocs/Cubits.
- `BlocListener` (or `MultiBlocListener` for merging multiple `BlocListener`, and eliminate need for nesting multiple `BlocListener`)
    - takes a `BlocWidgetListener` and an optional Bloc and invokes the `listener` in response to state changes in the bloc
    - should be used for side-effecting functionality that needs to occur once per state change such as navigation, showing a SnackBar, showing a Dialog, etc…
    - listen conditionally with `listenWhen`
    - unlike `BlocBuilder`, does *not* rebuild its child widget
    - You can often use `BlocListener` and `BlocBuilder` together to handle both UI updates and side effects in response to state changes
    - common use cases: analytics, error handling (SnackBar popups/dialogs mentioning errors), UI navigation, etc
- `BlocConsumer`
    - analogous to a nested `BlocListener` and `BlocBuilder` but reduces the amount of boilerplate needed
    - exposes a `builder` and `listener` in order to react to new states.
    - can potentially optimise performance by internally handling the subscription to the bloc's state stream only once, unlike a `BlocListener` and `BlocBuilder` pair each doing their own subscription
- `RepositoryProvider` (or `MultiRepositoryProvider` for merging, etc)
    - like `BlocProvider`, but instead of providing a bloc, it provides a repository to its tree of children
- (recap) Flutter repositories
    - repository is an abstraction layer that sits between your data sources (APIs, databases, local storage) and the rest of your application (typically Blocs/Cubits)
    - access (fetch/read), transform (raw to domain objects), cache (to eliminate future reads of the same data, and error handling)

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

