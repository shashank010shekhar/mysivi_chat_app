# MySivi Chat App

A modern Flutter chat application built with Clean Architecture, featuring real-time messaging, user management, and intelligent word meaning lookup.

**Author:** Shashank Shekhar Dubey

## 📱 Overview

MySivi Chat App is a feature-rich messaging application that demonstrates best practices in Flutter development, including:
- Clean Architecture with proper layer separation
- State management using Cubit (BLoC pattern)
- Dependency Injection with GetIt
- Comprehensive error handling
- Unit and integration testing
- Modern UI/UX with smooth animations

## 🏗️ Architecture

The application follows **Clean Architecture** principles with clear separation of concerns:

### Layer Structure

```
lib/
├── core/                    # Core functionality shared across features
│   ├── di/                  # Dependency injection setup
│   ├── errors/              # Error handling and exceptions
│   ├── models/              # Core data models
│   ├── routing/             # Navigation with GoRouter
│   ├── services/            # API and storage services
│   ├── theme/               # Centralized colors, text styles, strings
│   └── widgets/             # Reusable widgets
│
└── features/                # Feature-based modules
    ├── chat/                # Chat functionality
    │   ├── data/            # Data layer (repositories, models)
    │   ├── domain/          # Domain layer (entities, use cases, interfaces)
    │   └── presentation/    # Presentation layer (UI, Cubits, widgets)
    ├── users/               # User management
    ├── home/                # Home screen with tabs
    ├── offers/              # Offers feature (placeholder)
    └── settings/            # Settings feature (placeholder)
```

### Architecture Principles

1. **Domain Layer (Independent)**
   - Contains business logic and entities
   - No dependencies on other layers
   - Defines repository interfaces

2. **Data Layer**
   - Implements domain repository interfaces
   - Handles API calls and local storage
   - Maps between core models and domain entities

3. **Presentation Layer**
   - UI components and state management
   - Depends only on domain layer (use cases)
   - Uses Cubit for state management

4. **Dependency Flow**
   ```
   Presentation → Domain ← Data
   ```
   - Presentation and Data layers depend on Domain
   - Domain layer is completely independent

## ✨ Features

### 1. User Management
- **Users List Tab**: View all added users with:
  - Gradient avatars (blue-to-purple)
  - Online status indicators (green dot)
  - Last active timestamps
  - Scroll position preservation
- **Add User**: Floating action button to add new users by name
- **User Status**: Real-time online/offline status display

### 2. Chat Functionality
- **Chat History Tab**: View previous conversations with:
  - Solid color avatars (#00c47a)
  - Last message preview
  - Timestamp formatting (Just now, X min ago, Yesterday, etc.)
  - Unread message badges
  - Sticky AppBar
  - Scroll position preservation
- **Chat Screen**: Full conversation view with:
  - Message bubbles (sender: blue, receiver: gray)
  - Message grouping (avatars on last message of group)
  - Asymmetric bubble corners
  - Timestamp display
  - Auto-scroll to latest messages
  - Message input with send button

### 3. Intelligent Features
- **Word Meaning Lookup**: Long-press any word in a message to:
  - Fetch definition from dictionary API
  - Display in a bottom sheet with loading states
  - Graceful error handling

### 4. Message Flow
- **Sender Messages**: User-typed messages saved locally
- **Receiver Messages**: Automatically fetched from public APIs:
  - Primary: `dummyjson.com/comments`
  - Fallback: `api.quotable.io/random`
- **Auto-Response**: When you send a message, the app automatically fetches and displays a receiver response

### 5. UI/UX Features
- **Smooth Animations**: Tab switching with horizontal slide
- **Scroll Behavior**: AppBar hides/shows on scroll (Users tab only)
- **Loading States**: Skeletonizer for smooth loading placeholders
- **Error Handling**: Graceful error states with retry options
- **Empty States**: User-friendly empty state messages
- **Modern Design**: Clean, modern UI with Inter font family

## 🔧 How It Works

### 1. Application Initialization

```dart
main.dart
├── setupDependencyInjection()  // Register all dependencies
├── MaterialApp.router          // Configure GoRouter
└── AppTheme                    // Apply global theme
```

### 2. Dependency Injection

All dependencies are registered in `injection_container.dart`:
- **Services**: `ApiService`, `StorageService`
- **Repositories**: Domain interfaces → Data implementations
- **Use Cases**: Business logic operations

### 3. State Management Flow

```
User Action → Cubit → Use Case → Repository → Service → Response
                ↓
            State Update
                ↓
            UI Rebuild
```

**Example: Sending a Message**
1. User types and taps send
2. `ChatScreenCubit.sendMessage()` called
3. `SendMessageUseCase` executes
4. `ChatRepository.sendMessage()` saves to storage
5. `FetchReceiverMessageUseCase` gets response from API
6. `SaveReceiverMessageUseCase` saves response
7. `UpdateChatSessionUseCase` updates chat history
8. Cubit emits new state with updated messages
9. UI rebuilds with new messages

### 4. Data Persistence

- **Local Storage**: Uses `SharedPreferences` via `StorageService`
- **Data Models**: Core models stored as JSON
- **Entity Mapping**: Core models ↔ Domain entities

### 5. Error Handling

- **Custom Exceptions**: `AppException` hierarchy
- **Error Handler**: Centralized error conversion
- **Graceful Degradation**: App continues working even if APIs fail
- **User Feedback**: Error widgets with retry options

### 6. Navigation

- **GoRouter**: Declarative routing
- **Shell Routing**: Bottom navigation with persistent state
- **Route Parameters**: User ID and name passed to chat screen

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd mysivi_chat_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Build for Production

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## 🧪 Testing

The app includes comprehensive test coverage:

### Test Structure

```
test/
├── core/                    # Core service tests
│   └── services/
├── features/                # Feature tests
│   ├── chat/
│   │   ├── domain/         # Use case tests
│   │   └── presentation/   # Cubit tests
│   └── users/
│       ├── data/           # Repository tests
│       ├── domain/         # Use case tests
│       └── presentation/   # Cubit tests
└── integration/            # Integration tests
```

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/chat/presentation/cubit/chat_screen_cubit_test.dart
```

### Test Coverage

- ✅ **32 tests** passing
- ✅ Unit tests for use cases
- ✅ Unit tests for repositories
- ✅ Unit tests for services
- ✅ Cubit state management tests
- ✅ Integration tests for complete flows

## 📦 Dependencies

### Core Dependencies
- `flutter_bloc`: State management
- `get_it`: Dependency injection
- `go_router`: Navigation
- `http`: API calls
- `shared_preferences`: Local storage
- `equatable`: Value comparison
- `uuid`: Unique ID generation
- `intl`: Date/time formatting
- `google_fonts`: Inter font family
- `flutter_svg`: SVG rendering
- `skeletonizer`: Loading placeholders

### Dev Dependencies
- `flutter_test`: Testing framework
- `mockito`: Mocking for tests
- `bloc_test`: BLoC/Cubit testing
- `build_runner`: Code generation
- `integration_test`: Integration testing

## 🎨 Design System

### Colors
- **Primary**: `#175cfd` (Blue)
- **Background**: White
- **Sender Bubble**: `#175cfd`
- **Receiver Bubble**: `#f2f5f6`
- **Online Status**: `#01c475` (Green)
- **Chat History Avatar**: `#00c47a`

### Typography
- **Font Family**: Inter (Google Fonts)
- **Text Styles**: Centralized in `app_text_styles.dart`

### Theme
All colors, text styles, and strings are centralized in:
- `lib/core/theme/app_colors.dart`
- `lib/core/theme/app_text_styles.dart`
- `lib/core/theme/app_strings.dart`

## 🔄 Data Flow Example

### Adding a User

```
1. User taps FAB → AddUserDialog shown
2. User enters name → Dialog validates
3. UsersCubit.addUser() called
4. AddUserUseCase executes
5. UsersRepository.addUser() saves to StorageService
6. UsersCubit.loadUsers() refreshes list
7. UI updates with new user
```

### Sending a Message

```
1. User types message → Taps send
2. ChatScreenCubit.sendMessage() called
3. SendMessageUseCase saves sender message
4. UpdateChatSessionUseCase updates chat history
5. FetchReceiverMessageUseCase gets API response
6. SaveReceiverMessageUseCase saves receiver message
7. UpdateChatSessionUseCase updates again
8. ChatScreenCubit.loadMessages() refreshes
9. UI shows both messages
```

## 🛠️ Project Structure

```
mysivi_chat_app/
├── lib/
│   ├── core/               # Shared core functionality
│   ├── features/           # Feature modules
│   └── main.dart           # App entry point
├── test/                   # Test files
├── assets/                 # Images, fonts, etc.
├── pubspec.yaml           # Dependencies
└── README.md              # This file
```

## 📝 Key Design Decisions

1. **Clean Architecture**: Ensures maintainability and testability
2. **Feature-Based Structure**: Easy to scale and maintain
3. **Use Case Pattern**: Encapsulates business logic
4. **Dependency Injection**: Loose coupling, easy testing
5. **Error Handling**: Centralized and user-friendly
6. **State Management**: Cubit for simple, predictable state
7. **Centralized Theme**: Consistent UI across the app

## 🐛 Known Issues / Future Enhancements

- Offers and Settings tabs are placeholders
- Word meaning API may have rate limits
- No real-time synchronization (local storage only)

## 📄 License

This project is developed by **Shashank Shekhar Dubey**.

## 👤 Author

**Shashank Shekhar Dubey**

---

Built with ❤️ using Flutter and Clean Architecture principles.
