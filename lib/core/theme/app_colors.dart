import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary Colors
  static const Color primary = Color(0xFF175cfd);
  static const Color primaryDark = Color(0xFF0f4ac7);
  static const Color primaryLight = Color(0xFF3d7dfd);

  // Background Colors
  static const Color background = Colors.white;
  static const Color backgroundSecondary = Color(0xFFf2f5f6);
  static const Color backgroundTertiary = Color(0xfff3f4f6);

  // Text Colors
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textWhite = Colors.white;

  // Status Colors
  static const Color online = Color(0xFF01c475);
  static const Color offline = Colors.grey;
  
  // Chat History Avatar Color
  static const Color chatHistoryAvatar = Color(0xFF00c47a);

  // Message Bubble Colors
  static const Color senderBubble = Color(0xFF175cfd);
  static const Color receiverBubble = Color(0xFFf2f5f6);

  // Gradient Colors
  static const Color gradientStart = Color(0xFF6366F1); // Purple
  static const Color gradientEnd = Color(0xFF3B82F6); // Blue

  // Avatar Gradient Colors
  static List<Color> get avatarGradientBlue => [
        Colors.blue.shade400,
        Colors.purple.shade400,
      ];

  static List<Color> get avatarGradientPurple => [
        Colors.purple.shade400,
        Colors.pink.shade400,
      ];

  // Shadow Colors
  static Color shadowLight = Colors.grey.withValues(alpha: 0.1);
  static Color shadowMedium = Colors.grey.withValues(alpha: 0.3);
  static Color shadowDark = Colors.grey.withValues(alpha: 0.5);

  // Border Colors
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderMedium = Color(0xFFD1D5DB);
}

