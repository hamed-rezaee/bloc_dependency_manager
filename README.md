# Bloc Dependency Manager

**Bloc Dependency Manager** is a centralized dependency management package designed to simplify the handling, registration, and lifecycle management of BLoCs (Business Logic Components) in Dart and Flutter applications. It provides an organized way to manage BLoC dependencies, add custom state listeners, and handle event dispatching through a core state management system.

This package aims to help developers avoid repetitive setup and cleanup tasks, minimize dependency conflicts, and create scalable and maintainable architectures in Flutter applications.

## How It Works

The **Bloc Dependency Manager** package manages BLoCs and their state communications through a central `BlocManager`, using several key classes and design patterns to simplify dependency handling, state changes, and event-driven communication.

### Architecture Overview

1. **`BlocManager`** - A singleton class that provides centralized BLoC registration, lazy loading, and listener management.
2. **`StateDispatcher`** - Manages and dispatches state emitters, which are used to handle and distribute BLoC state changes.
3. **`BaseStateEmitter`** - An abstract base class for creating custom state emitters that define how different states should be handled for specific listeners.
4. **`BaseStateListener`** - An interface to define actions for listeners to respond to BLoC state changes.

### Core Design Patterns

- **Singleton Pattern**: Ensures only one `BlocManager` instance exists across the app.
- **Dependency Injection**: BLoCs are registered with `BlocManager` and can be lazily or eagerly instantiated.
- **Observer Pattern**: `BlocManager` notifies listeners of state changes, allowing them to respond independently.
- **Strategy Pattern**: `StateEmitters` handle different strategies for managing state changes.

## Key Features

- **Centralized BLoC Management:** Register and manage all BLoCs through a single BlocManager instance.
- **Lazy and Eager Registration:** Register BLoCs only when needed or immediately, based on your app’s requirements.
- **State Emission and Custom Listeners:** Attach state listeners and create custom emitters to manage and track state changes across BLoCs.
- **Automated Resource Disposal:** Dispose of BLoCs and related listeners automatically to prevent memory leaks.
- **Seamless Integration with BLoC Library:** Works smoothly with the bloc package to manage state across applications.

## How It Works

The **Bloc Dependency Manager** operates through several primary components:

1. **BlocManager:** A singleton class that manages the lifecycle of BLoCs, storing them in a repository and handling their registration and disposal.
2. **BaseStateEmitter:** A base class for custom state emitters, which trigger specific actions when a BLoC's state changes.
3. **StateDispatcher:** Registers and manages custom emitters, allowing multiple state listeners to react to changes in the central BlocManager.
4. **BaseStateListener:** An abstract class for defining behaviors for state listeners, allowing you to implement custom response methods to BLoC state changes.

## Getting Started

Here's a complete walkthrough to demonstrate how to set up and use the **Bloc Dependency Manager**.

### 1. Create a BLoC

Define a BLoC (`CounterBloc`) that will emit states based on user actions:

```dart
enum CounterState { increment, decrement, reset }

class CounterBloc extends Cubit<CounterState> {
  CounterBloc() : super(CounterState.reset);

  void reset() {
    emit(CounterState.reset);
  }

  void increment() {
    emit(CounterState.increment);
  }

  void decrement() {
    emit(CounterState.decrement);
  }
}
```

In this example, the `CounterBloc` emits `CounterState.increment`, `CounterState.decrement`, or `CounterState.reset` based on the method called.

### 2. Define a State Listener Interface

Create a listener interface for responding to changes in the `CounterBloc` state.

```dart
abstract class CounterStateListener extends BaseStateListener {
  void onCounterStateReset();
  void onCounterStateChange(CounterState state);
}
```

Here, `CounterStateListener` defines the methods that will be triggered when specific states are emitted by the `CounterBloc`.

### 3. Implement a Custom State Emitter

Use a `CounterStateEmitter` to broadcast state changes to listeners:

```dart
class CounterStateEmitter extends BaseStateEmitter<CounterStateListener, CounterBloc> {
  CounterStateEmitter(super.blocManager);

  @override
  void handleStates({
    required CounterStateListener stateListener,
    required Object? state,
  }) {
    switch (state) {
      case CounterState.reset:
        stateListener.onCounterStateReset();
        break;
      case CounterState.increment:
        stateListener.onCounterStateChange(CounterState.increment);
        break;
      case CounterState.decrement:
        stateListener.onCounterStateChange(CounterState.decrement);
        break;
      default:
        throw UnimplementedError();
    }
  }
}
```

The `CounterStateEmitter` listens to `CounterBloc` changes and invokes methods in `CounterStateListener` depending on the current state of `CounterBloc`.

### 4. Create a Logger Bloc for Tracking Changes

Implement a `LoggerBloc` that listens to `CounterStateListener` and logs state changes.

```dart
class LoggerBloc extends Cubit<String> implements CounterStateListener {
  LoggerBloc() : super('');

  @override
  void onCounterStateReset() {
    emit('Counter state has been reset.');
  }

  @override
  void onCounterStateChange(CounterState counterState) {
    emit('Counter state changed to $counterState.');
  }
}
```

In `LoggerBloc`, the state is emitted as a log message whenever the counter state changes.

### 5. Set up and Use BlocManager

Register `LoggerBloc`, `CounterBloc`, and the custom `CounterStateEmitter` in `BlocManager` and dispatch some events to test the setup.

```dart
Future<void> main() async {
  // Register blocs with the BlocManager
  BlocManager().register(LoggerBloc());
  BlocManager().register(CounterBloc());

  // Register the state emitter to manage state emissions for CounterBloc.
  StateDispatcher(BlocManager()).register<CounterBloc, CounterStateEmitter>(
    (BaseBlocManager blocManager) => CounterStateEmitter(blocManager as BlocManager),
  );

  // Listen to LoggerBloc's state to see logged messages
  BlocManager().fetch<LoggerBloc>().stream.listen(print);

  // Fetch CounterBloc and dispatch actions
  final counterBloc = BlocManager().fetch<CounterBloc>();
  counterBloc.decrement();
  await Future<void>.delayed(Duration(seconds: 1));
  counterBloc.increment();
  await Future<void>.delayed(Duration(seconds: 1));
  counterBloc.reset();

  // Clean up all registered BLoCs
  await BlocManager().dispose();

  print('All BLoCs disposed.');
}
```

### Explanation of the Flow

1. **Bloc Registration:** Both `CounterBloc` and `LoggerBloc` are registered with `BlocManager` for centralized access.
2. **State Emitter Registration:** The `CounterStateEmitter` is registered to handle state emissions for `CounterBloc` by using `StateDispatcher`.
3. **Event Dispatch:** Actions are dispatched to `CounterBloc` (increment, decrement, reset), causing state changes.
4. **State Listening:** `LoggerBloc`, registered as a `CounterStateListener`, responds to each state change and logs the output.
5. **Cleanup:** Finally, `BlocManager().dispose()` is called to clean up all registered blocs and listeners.

## API Reference

### BlocManager

The main singleton class for managing the lifecycle of BLoCs and providing centralized access to registered instances.

#### Methods

- **`register<B>()`**
  - Registers a BLoC instance of type `B`.
  - **Parameters**:
    - `B bloc`: The BLoC instance to register.
    - `String key` (optional): The identifier for the BLoC; defaults to `defaultKey`.
  - **Returns**: The registered BLoC instance.
- **`lazyRegister<B>()`**
  - Registers a BLoC with a factory function, creating the instance only when it's first requested.
  - **Parameters**:
    - `Function predicate`: The function to create the BLoC instance when needed.
    - `String key` (optional): The identifier for the BLoC; defaults to `defaultKey`.
- **`fetch<B>()`**

  - Retrieves a registered BLoC by its type and optional key.
  - **Parameters**:
    - `String key` (optional): Identifier for the BLoC to fetch; defaults to `defaultKey`.
  - **Returns**: The fetched BLoC instance.
  - **Throws**: `BlocManagerException` if the BLoC is not registered.

- **`isBlocRegistered<B>()`**

  - Checks if a BLoC of a certain type and key is registered.
  - **Parameters**:
    - `String key`: The identifier for the BLoC.
  - **Returns**: `true` if the BLoC is registered, `false` otherwise.

- **`addListener<B>()`**

  - Adds a listener to a registered BLoC to listen for state changes.
  - **Parameters**:
    - `String listenerKey`: Identifier for the listener.
    - `BlocManagerListenerHandler handler`: Callback to execute when the BLoC's state changes.
    - `String key` (optional): Identifier for the BLoC; defaults to `defaultKey`.

- **`hasListener<B>()`**

  - Checks if a listener with a specific key exists for a registered BLoC.
  - **Parameters**:
    - `String key`: The identifier for the listener.
  - **Returns**: `true` if the listener exists, `false` otherwise.

- **`removeListener<B>()`**

  - Removes a listener associated with a specific BLoC and key.
  - **Parameters**:
    - `String key` (optional): Identifier for the listener; defaults to `defaultKey`.
  - **Returns**: A `Future` that completes when the listener is removed.

- **`registerStateEmitter()`**

  - Registers a custom state emitter that listens for and processes specific state changes.
  - **Parameters**:
    - `GenericStateEmitter stateEmitter`: The state emitter to register.

- **`emitCoreStates<E>()`**

  - Dispatches states to all registered state emitters for a specific BLoC.
  - **Parameters**:
    - `GenericBloc bloc`: The BLoC for which the state is emitted.
    - `Object? state`: The state to emit to listeners.

- **`dispose<B>()`**
  - Disposes a registered BLoC and removes any associated listeners.
  - **Parameters**:
    - `String key` (optional): Identifier for the BLoC to dispose; defaults to `defaultKey`.
  - **Returns**: A `Future` that completes when the BLoC is disposed.

### StateDispatcher

The `StateDispatcher` class is a helper that registers state emitters for specified BLoCs, allowing listeners to be triggered on BLoC state changes.

#### Methods

- **`register<B, E>()`**
  - Registers a state emitter of type `E` for a BLoC of type `B`, enabling state emission to be managed centrally.
  - **Parameters**:
    - `StateEmitterBuilder stateEmitterBuilder`: A builder function to initialize the state emitter with the `BlocManager`.

### BaseStateEmitter

The `BaseStateEmitter` is an abstract class for creating custom state emitters that broadcast state changes to listeners. It’s designed to be extended to implement specific behaviors based on BLoC state changes.

#### Methods

- **`handleStates()`**

  - Defines how states are handled for a specific state listener.
  - **Parameters**:
    - `BaseStateListener stateListener`: The listener that will respond to state changes.
    - `Object state`: The state being emitted by the BLoC.

- **`call()`**
  - Triggers the emission of the current state to the listener, with optional handling for a custom state.
  - **Parameters**:
    - `BaseStateListener stateListener`: The listener to receive the state.
    - `Object? state`: The state to emit. Defaults to the BLoC’s current state if not provided.

### BaseStateListener

An abstract class for creating listener interfaces to respond to specific state changes in BLoCs. Implementing classes define the actions that occur in response to BLoC state changes.

#### Methods

- Implement custom methods in classes that extend `BaseStateListener` to define responses to specific states (e.g., `onCounterStateReset`, `onCounterStateChange` in a `CounterStateListener` implementation).

## Contributing

Contributions to the **Bloc Dependency Manager** package are welcome.
Feel free to submit issues, feature requests, or pull requests to help improve the package and make it more useful for the Flutter community.
