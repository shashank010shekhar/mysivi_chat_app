import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_strings.dart';
import '../../../users/presentation/cubit/users_cubit.dart';
import '../../../users/presentation/widgets/users_list_widget.dart';
import '../../../users/domain/usecases/get_users_usecase.dart';
import '../../../users/domain/usecases/add_user_usecase.dart';
import '../../../chat/presentation/cubit/chat_history_cubit.dart';
import '../../../chat/presentation/widgets/chat_history_widget.dart';
import '../../../chat/domain/usecases/get_chat_sessions_usecase.dart';
import '../../../chat/domain/usecases/mark_messages_read_usecase.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/modern_toast.dart';
import '../../../../core/routing/app_router.dart';
import '../widgets/add_user_dialog.dart';

enum HomeTab { users, chatHistory }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeTab _currentTab = HomeTab.users;
  final ScrollController _usersScrollController = ScrollController();
  final ScrollController _chatHistoryScrollController = ScrollController();
  bool _showAppBar = true;
  double _lastUsersScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _usersScrollController.addListener(_onUsersScroll);
    _chatHistoryScrollController.addListener(_onChatHistoryScroll);
  }

  @override
  void dispose() {
    _usersScrollController.removeListener(_onUsersScroll);
    _chatHistoryScrollController.removeListener(_onChatHistoryScroll);
    _usersScrollController.dispose();
    _chatHistoryScrollController.dispose();
    super.dispose();
  }

  void _onUsersScroll() {
    // Only handle scroll for Users tab
    if (_currentTab == HomeTab.users) {
      _handleScroll(_usersScrollController, _lastUsersScrollOffset, (offset) {
        _lastUsersScrollOffset = offset;
      });
    }
  }

  void _onChatHistoryScroll() {
    // Chat History tab - AppBar is always visible (sticky), no hide/show behavior
    // Just save scroll position for the cubit (handled by ChatHistoryWidget itself)
    // No need to do anything here since the widget handles its own scroll position
  }

  void _handleScroll(ScrollController controller, double lastOffset, Function(double) updateLastOffset) {
    if (!controller.hasClients) return;

    final currentOffset = controller.offset;
    final scrollDelta = currentOffset - lastOffset;
    
    // Always show AppBar when at the top
    if (currentOffset <= 0) {
      if (!_showAppBar) {
        setState(() {
          _showAppBar = true;
        });
      }
      updateLastOffset(currentOffset);
      return;
    }
    
    // Only update if there's a meaningful scroll change (at least 3px)
    if (scrollDelta.abs() < 3) {
      updateLastOffset(currentOffset);
      return;
    }
    
    // Show AppBar when scrolling up
    if (scrollDelta < 0) {
      if (!_showAppBar) {
        setState(() {
          _showAppBar = true;
        });
      }
    } 
    // Hide AppBar when scrolling down and past threshold
    else if (scrollDelta > 0 && currentOffset > 20) {
      if (_showAppBar) {
        setState(() {
          _showAppBar = false;
        });
      }
    }
    
    updateLastOffset(currentOffset);
  }

  void _onUserTap(BuildContext contextWithProvider, String userId, String userName) {
    // Mark messages as read when opening chat from chat history
    final markMessagesReadUseCase = getIt<MarkMessagesReadUseCase>();
    markMessagesReadUseCase(userId).then((_) {
      // Refresh chat history to update unread count immediately
      if (mounted && contextWithProvider.mounted) {
        contextWithProvider.read<ChatHistoryCubit>().refresh();
      }
    });
    
    // Navigate using go_router
    contextWithProvider.push(
      '${AppRouter.chat}/${Uri.encodeComponent(userId)}/${Uri.encodeComponent(userName)}',
    ).then((_) {
      // Refresh chat history when returning from chat screen
      if (mounted && contextWithProvider.mounted) {
        contextWithProvider.read<ChatHistoryCubit>().refresh();
      }
    });
  }

  void _showAddUserDialog(BuildContext contextWithProvider) {
    final nameController = TextEditingController();
    // Use the context that has access to the providers
    final usersCubit = contextWithProvider.read<UsersCubit>();
    
    showDialog(
      context: contextWithProvider,
      barrierColor: AppColors.shadowDark,
      builder: (dialogContext) => AddUserDialog(
        nameController: nameController,
        onCancel: () => Navigator.pop(dialogContext),
        onAdd: () {
          final name = nameController.text.trim();
          if (name.isNotEmpty) {
            usersCubit.addUser(name);
            Navigator.pop(dialogContext);
            ModernToast.show(
              contextWithProvider,
              message: AppStrings.userAdded.replaceAll('{name}', name),
              icon: Icons.check_circle,
              backgroundColor: AppColors.primary,
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => UsersCubit(
            getIt<GetUsersUseCase>(),
            getIt<AddUserUseCase>(),
          ),
        ),
        BlocProvider(
          create: (context) => ChatHistoryCubit(
            getIt<GetChatSessionsUseCase>(),
          ),
        ),
      ],
      child: Builder(
        builder: (contextWithProvider) => Scaffold(
          backgroundColor: AppColors.background,
          extendBodyBehindAppBar: false,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            surfaceTintColor: AppColors.background,
            elevation: 0.5,
            shadowColor: AppColors.shadowMedium,
            automaticallyImplyLeading: false,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            toolbarHeight: (_showAppBar || _currentTab == HomeTab.chatHistory) ? null : 0,
            title: AnimatedOpacity(
              opacity: (_showAppBar || _currentTab == HomeTab.chatHistory) ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: _CustomTabSwitcher(
                currentTab: _currentTab,
                onTabChanged: (tab) {
                  setState(() {
                    _currentTab = tab;
                    // When switching to Chat History, ensure AppBar is visible
                    if (tab == HomeTab.chatHistory) {
                      _showAppBar = true;
                    }
                  });
                },
              ),
            ),
            centerTitle: true,
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final screenWidth = constraints.maxWidth;
              return Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: _currentTab == HomeTab.users ? 0 : -screenWidth,
                    right: _currentTab == HomeTab.users ? 0 : screenWidth,
                    top: 0,
                    bottom: 0,
                    child: SizedBox(
                      width: screenWidth,
                      child: UsersListWidget(
                        scrollController: _usersScrollController,
                        onUserTap: (userId, userName) => _onUserTap(contextWithProvider, userId, userName),
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: _currentTab == HomeTab.chatHistory ? 0 : screenWidth,
                    right: _currentTab == HomeTab.chatHistory ? 0 : -screenWidth,
                    top: 0,
                    bottom: 0,
                    child: SizedBox(
                      width: screenWidth,
                      child: ChatHistoryWidget(
                        scrollController: _chatHistoryScrollController,
                        onSessionTap: (userId, userName) => _onUserTap(contextWithProvider, userId, userName),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          floatingActionButton: _currentTab == HomeTab.users
              ? FloatingActionButton(
                  onPressed: () => _showAddUserDialog(contextWithProvider),
                  backgroundColor: AppColors.primary,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.add, color: AppColors.textWhite),
                )
              : null,
        ),
      ),
    );
  }
}

class _CustomTabSwitcher extends StatefulWidget {
  final HomeTab currentTab;
  final Function(HomeTab) onTabChanged;

  const _CustomTabSwitcher({
    required this.currentTab,
    required this.onTabChanged,
  });

  @override
  State<_CustomTabSwitcher> createState() => _CustomTabSwitcherState();
}

class _CustomTabSwitcherState extends State<_CustomTabSwitcher> {
  final GlobalKey _usersButtonKey = GlobalKey();
  final GlobalKey _chatHistoryButtonKey = GlobalKey();
  double _usersButtonWidth = 80;
  double _chatHistoryButtonWidth = 110;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureButtonWidths();
    });
  }

  void _measureButtonWidths() {
    final usersBox = _usersButtonKey.currentContext?.findRenderObject() as RenderBox?;
    final chatHistoryBox = _chatHistoryButtonKey.currentContext?.findRenderObject() as RenderBox?;
    
    if (usersBox != null && chatHistoryBox != null) {
      setState(() {
        _usersButtonWidth = usersBox.size.width;
        _chatHistoryButtonWidth = chatHistoryBox.size.width;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: AppColors.backgroundTertiary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TabButton(
                key: _usersButtonKey,
                label: AppStrings.tabUsers,
                isSelected: false,
                onTap: () {
                  widget.onTabChanged(HomeTab.users);
                  WidgetsBinding.instance.addPostFrameCallback((_) => _measureButtonWidths());
                },
              ),
              _TabButton(
                key: _chatHistoryButtonKey,
                label: AppStrings.tabChatHistory,
                isSelected: false,
                onTap: () {
                  widget.onTabChanged(HomeTab.chatHistory);
                  WidgetsBinding.instance.addPostFrameCallback((_) => _measureButtonWidths());
                },
              ),
            ],
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: widget.currentTab == HomeTab.users ? 3 : null,
            right: widget.currentTab == HomeTab.chatHistory ? 3 : null,
            top: 2,
            bottom: 3,
            child: Container(
              width: widget.currentTab == HomeTab.users ? _usersButtonWidth : _chatHistoryButtonWidth,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TabButton(
                label: AppStrings.tabUsers,
                isSelected: widget.currentTab == HomeTab.users,
                onTap: () => widget.onTabChanged(HomeTab.users),
              ),
              _TabButton(
                label: AppStrings.tabChatHistory,
                isSelected: widget.currentTab == HomeTab.chatHistory,
                onTap: () => widget.onTabChanged(HomeTab.chatHistory),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: isSelected 
              ? AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary)
              : AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

