class AppStrings {
  AppStrings._(); // Private constructor to prevent instantiation

  // App Name
  static const String appName = 'MySivi Chat App';

  // Navigation Labels
  static const String navHome = 'Home';
  static const String navOffers = 'Offers';
  static const String navSettings = 'Settings';

  // Home Screen
  static const String tabUsers = 'Users';
  static const String tabChatHistory = 'Chat History';

  // Users
  static const String noUsers = 'No users yet.\nTap the + button to add a user.';
  static const String userAdded = 'User "{name}" added successfully';
  static const String addUser = 'Add User';
  static const String enterUserName = 'Enter user name';
  static const String cancel = 'Cancel';
  static const String add = 'Add';
  static const String online = 'Online';
  static const String offline = 'Offline';

  // Chat History
  static const String noChatHistory = 'No chat history yet.\nStart a conversation from the Users tab.';
  static const String lastMessagePlaceholder = 'No messages yet';
  static const String justNow = 'Just now';
  static const String minutesAgo = '{count} min ago';
  static const String hoursAgo = '{count} hour{plural} ago';
  static const String yesterday = 'Yesterday';
  static const String daysAgo = '{count} days ago';

  // Chat Screen
  static const String typeMessage = 'Type a message...';
  static const String sending = 'Sending...';
  static const String noMessages = 'No messages yet.\nStart the conversation!';

  // Word Meaning
  static const String meaning = 'Meaning:';
  static const String noMeaningFound = 'No meaning found for "{word}".';
  static const String couldNotFetchMeaning = 'Could not fetch meaning. Please try again.';

  // Errors
  static const String errorLoadingUsers = 'Error loading users';
  static const String errorLoadingChatHistory = 'Error loading chat history';
  static const String errorLoadingMessages = 'Error loading messages';
  static const String errorSendingMessage = 'Error sending message';
  static const String retry = 'Retry';

  // Time Formatting
  static String formatMinutesAgo(int minutes) => minutes == 1 
      ? minutesAgo.replaceAll('{count}', '1')
      : minutesAgo.replaceAll('{count}', minutes.toString());

  static String formatHoursAgo(int hours) {
    final plural = hours > 1 ? 's' : '';
    return hoursAgo
        .replaceAll('{count}', hours.toString())
        .replaceAll('{plural}', plural);
  }

  static String formatDaysAgo(int days) => daysAgo.replaceAll('{count}', days.toString());
}

