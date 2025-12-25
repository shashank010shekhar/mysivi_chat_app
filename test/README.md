# Testing Guide

This directory contains comprehensive unit and integration tests for the MySivi Chat App.

## Test Structure

```
test/
├── features/
│   ├── users/
│   │   ├── domain/
│   │   │   └── usecases/
│   │   │       ├── get_users_usecase_test.dart
│   │   │       └── add_user_usecase_test.dart
│   │   ├── data/
│   │   │   └── repositories/
│   │   │       └── users_repository_test.dart
│   │   └── presentation/
│   │       └── cubit/
│   │           └── users_cubit_test.dart
│   └── chat/
│       ├── domain/
│       │   └── usecases/
│       │       └── send_message_usecase_test.dart
│       └── presentation/
│           └── cubit/
│               └── chat_screen_cubit_test.dart
├── core/
│   └── services/
│       ├── api_service_test.dart
│       └── storage_service_test.dart
└── integration/
    └── chat_flow_test.dart
```

## Running Tests

### Run all tests
```bash
flutter test
```

### Run specific test file
```bash
flutter test test/features/users/domain/usecases/get_users_usecase_test.dart
```

### Run tests with coverage
```bash
flutter test --coverage
```

### Generate mock files
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Test Categories

### Unit Tests

1. **Use Case Tests**: Test business logic in isolation
   - `get_users_usecase_test.dart`
   - `add_user_usecase_test.dart`
   - `send_message_usecase_test.dart`

2. **Cubit Tests**: Test state management logic
   - `users_cubit_test.dart`
   - `chat_screen_cubit_test.dart`

3. **Service Tests**: Test core services
   - `api_service_test.dart`
   - `storage_service_test.dart`

4. **Repository Tests**: Test data layer implementations
   - `users_repository_test.dart`

### Integration Tests

- `chat_flow_test.dart`: Tests complete user flows across multiple layers

## Architecture Compliance

All tests maintain clean architecture principles:

- **Domain Layer**: Tests use mocks of repository interfaces
- **Data Layer**: Tests use mocks of services
- **Presentation Layer**: Tests use mocks of use cases
- **No Circular Dependencies**: Tests follow dependency inversion

## Mock Generation

Tests use `mockito` for generating mocks. After adding new test files with `@GenerateMocks`, run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Best Practices

1. **Isolation**: Each test is independent and doesn't rely on other tests
2. **Mocks**: Use mocks to isolate units under test
3. **Arrange-Act-Assert**: Follow AAA pattern in tests
4. **Coverage**: Aim for high test coverage, especially for business logic
5. **Architecture**: Maintain clean architecture boundaries in tests

