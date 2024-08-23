# flutter_default_skeleton_project

Converting the default Flutter skeleton project to a BLoC-powered app.

Some learnings:
- BLoC's Cubits remind me of Riverpod (see note 1) in that it simplifies state management via direct state mutation via methods, with less boilerplate
- Cubit's bigger sibling is Bloc, but instead of calling functions to mutate state, Bloc receives incoming events, which it converts into outgoing states via your business logic
- Cubit and Bloc state changes can be centrally observed via a BlocObserver by setting Bloc.observer
- Cubit and Bloc both extend BlocBase (which is the base type the BlocObserver accepts in its handlers)