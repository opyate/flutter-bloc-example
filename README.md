# flutter_default_skeleton_project

Converting the default Flutter skeleton project to a BLoC-powered app.

Some learnings:
- BLoC's Cubits remind me of Riverpod (see [Note 1](#note-1)) in that it simplifies state management via direct state mutation via methods, with less boilerplate
- Cubit's bigger sibling is Bloc, but instead of calling functions to mutate state, Bloc receives incoming events, which it converts into outgoing states via your business logic
- Cubit and Bloc state changes can be centrally observed via a BlocObserver by setting Bloc.observer
- Cubit and Bloc both extend BlocBase (which is the base type the BlocObserver accepts in its handlers)
- Bloc advantages:
    - event sourcing (traceability)


## Notes

# Note 1

Riverpod is what [Andrea](https://codewithandrea.com/) used in our receipt scanner project for DunnHumby; I had the mobile app checked out and running on my computer too and sent a few PRs; likewise, Andrea learned about Firebase from me and incorporated it into his courses.