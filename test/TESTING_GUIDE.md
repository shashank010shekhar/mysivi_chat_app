# Testing Guide - Understanding Cubit State Timing Issues

## Problem: Constructor Async Calls

Both `UsersCubit` and `ChatScreenCubit` call async methods in their constructors:

```dart
UsersCubit(this._getUsersUseCase, this._addUserUseCase) : super(const UsersState()) {
  loadUsers(); // This emits states immediately!
}
```

This means when we create a cubit in tests, it automatically starts emitting states before the test can set up expectations.

## How bloc_test Works

`bloc_test` captures states in this order:
1. **Initial state** - The state passed to `super()` in constructor
2. **States from constructor** - Any states emitted during construction
3. **States from `act()`** - States emitted by actions in the test
4. **States from `wait`** - States emitted after waiting

## The Issue

When a cubit constructor calls an async method:
- The async method starts executing
- States are emitted asynchronously
- `bloc_test` needs to wait for these states
- If we don't account for them, tests fail

## Solutions

### Solution 1: Use Regular `test()` Instead of `blocTest()` (Recommended)

For cubits with constructor async calls, use regular `test()` with `Future.delayed()`:

```dart
test('loads users successfully', () async {
  // Arrange
  when(mockUseCase()).thenAnswer((_) async => result);
  
  // Act - Constructor calls loadUsers()
  final cubit = UsersCubit(mockUseCase, ...);
  
  // Wait for constructor's async call to complete
  await Future.delayed(const Duration(milliseconds: 300));
  
  // Assert
  expect(cubit.state.isLoading, false);
  expect(cubit.state.users, isNotEmpty);
  cubit.close();
});
```

**Why this works:**
- We create the cubit and immediately wait for the async operation
- Then we assert the final state
- No need to track intermediate states

### Solution 2: Use `blocTest` with Proper `wait` (For State Transitions)

If you need to test state transitions, use `blocTest` with appropriate `wait`:

```dart
blocTest<UsersCubit, UsersState>(
  'test name',
  build: () {
    when(mockUseCase()).thenAnswer((_) async => result);
    return UsersCubit(mockUseCase, ...);
  },
  wait: const Duration(milliseconds: 300), // Wait for constructor's async call
  expect: () => [
    const UsersState(isLoading: true, users: []),
    UsersState(isLoading: false, users: result),
  ],
);
```

**Note:** This only works if states are emitted synchronously or within the wait period.

## Current Test Failures Explained

### 1. "saves scroll position" Test
**Problem**: Constructor emits 2 states (loading → loaded), then `saveScrollPosition` emits 1 more state.
**Solution**: Use regular `test()` and wait for constructor to complete before testing

### 2. "emits [loading, error]" Test  
**Problem**: Constructor's async call throws exception, but states aren't captured properly by `blocTest`.
**Solution**: Use regular `test()` and wait for the error state

### 3. Chat Screen Tests
**Problem**: Similar to UsersCubit - constructor calls `loadMessages()` immediately.
**Solution**: Use regular `test()` with proper async/await

## Best Practices

1. **For constructor async calls**: Use regular `test()` with `Future.delayed()`
2. **For state transitions**: Use `blocTest()` only when you can control when states are emitted
3. **Always wait**: Give async operations time to complete before assertions
4. **Test behavior, not implementation**: Focus on what the cubit does, not how many states it emits
5. **Close cubits**: Always close cubits in tests to prevent memory leaks

## Architecture Note

The constructor calls are intentional for UX (loading data immediately), but they make testing more complex. The tests still verify correct behavior - they just need to account for the constructor's async operations using `Future.delayed()`.

## Example: Working Test Pattern

```dart
test('cubit behavior test', () async {
  // 1. Arrange - Set up mocks
  when(mockUseCase()).thenAnswer((_) async => result);
  
  // 2. Act - Create cubit (triggers constructor async call)
  final cubit = MyCubit(mockUseCase);
  
  // 3. Wait - Let constructor's async operation complete
  await Future.delayed(const Duration(milliseconds: 300));
  
  // 4. Assert - Verify final state
  expect(cubit.state.isLoading, false);
  expect(cubit.state.data, isNotEmpty);
  
  // 5. Cleanup
  cubit.close();
});
```
