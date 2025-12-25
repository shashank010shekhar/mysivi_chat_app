class AppConstants {
  AppConstants._(); // Private constructor to prevent instantiation

  // API Endpoints
  static const String dummyJsonComments = 'https://dummyjson.com/comments?limit=10';
  static const String quotableApi = 'https://api.quotable.io/random';
  static const String dictionaryApi = 'https://api.dictionaryapi.dev/api/v2/entries/en/';
  
  // Storage Keys
  static const String usersKey = 'users';
  static const String messagesKey = 'messages';
  static const String chatSessionsKey = 'chat_sessions';
  
  // UI Constants
  static const double messageBubbleRadius = 16.0;
  static const double messageBubbleRadiusSmall = 4.0;
  static const double avatarRadius = 20.0;
  static const double avatarSize = 40.0;
  static const double avatarSizeSmall = 48.0;
  static const double horizontalPadding = 16.0;
  static const double verticalPadding = 8.0;
  static const double messageMaxWidth = 0.58; // 58% of screen width
  static const double messagePadding = 14.0;
  static const double messageVerticalPadding = 10.0;
  static const double messageSpacing = 4.0;
  static const double messageBottomSpacing = 12.0;
  
  // Animation Durations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  
  // Scroll Thresholds
  static const double scrollThreshold = 20.0;
  static const double scrollDeltaThreshold = 3.0;
}

