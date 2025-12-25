import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_strings.dart';
import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/chat/presentation/pages/chat_screen.dart';
import '../../features/offers/presentation/pages/offers_screen.dart';
import '../../features/settings/presentation/pages/settings_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String chat = '/chat';
  static const String offers = '/offers';
  static const String settings = '/settings';

  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    initialLocation: home,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return _MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: home,
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: offers,
            name: 'offers',
            builder: (context, state) => const OffersScreen(),
          ),
          GoRoute(
            path: settings,
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '$chat/:userId/:userName',
        name: 'chat',
        builder: (context, state) {
          final userId = Uri.decodeComponent(state.pathParameters['userId']!);
          final userName = Uri.decodeComponent(state.pathParameters['userName']!);
          return ChatScreen(
            userId: userId,
            userName: userName,
          );
        },
      ),
    ],
  );
}

class _MainShell extends StatelessWidget {
  final Widget child;

  const _MainShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _BottomNavigationBar(),
    );
  }
}

class _BottomNavigationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.path;
    
    int currentIndex = 0;
    if (currentLocation == AppRouter.offers) {
      currentIndex = 1;
    } else if (currentLocation == AppRouter.settings) {
      currentIndex = 2;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: AppColors.background,
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.offline,
        elevation: 0,
        selectedLabelStyle: AppTextStyles.navLabel,
        unselectedLabelStyle: AppTextStyles.navLabel,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go(AppRouter.home);
              break;
            case 1:
              context.go(AppRouter.offers);
              break;
            case 2:
              context.go(AppRouter.settings);
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/svg/chat-bubble-svgrepo-com.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                currentIndex == 0 ? AppColors.primary : AppColors.offline,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.asset(
              'assets/svg/chat-bubble-svgrepo-com.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
            label: AppStrings.navHome,
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/svg/ic_outline-local-offer.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                currentIndex == 1 ? AppColors.primary : AppColors.offline,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.asset(
              'assets/svg/ic_outline-local-offer.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
            label: AppStrings.navOffers,
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/svg/lucide_settings.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                currentIndex == 2 ? AppColors.primary : AppColors.offline,
                BlendMode.srcIn,
              ),
            ),
            activeIcon: SvgPicture.asset(
              'assets/svg/lucide_settings.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
            label: AppStrings.navSettings,
          ),
        ],
      ),
    );
  }
}

