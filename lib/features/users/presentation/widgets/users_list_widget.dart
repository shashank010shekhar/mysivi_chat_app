import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubit/users_cubit.dart';
import '../cubit/users_state.dart';
import '../../domain/entities/user_entity.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_strings.dart';
import '../../../../core/widgets/error_widget.dart';

class UsersListWidget extends StatefulWidget {
  final ScrollController? scrollController;
  final Function(String userId, String userName) onUserTap;

  const UsersListWidget({
    super.key,
    this.scrollController,
    required this.onUserTap,
  });

  @override
  State<UsersListWidget> createState() => _UsersListWidgetState();
}

class _UsersListWidgetState extends State<UsersListWidget> {
  late ScrollController _scrollController;
  bool _isInitialized = false;
  String? _selectedUserId;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    final cubit = context.read<UsersCubit>();
    cubit.saveScrollPosition(_scrollController.offset);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final cubit = context.read<UsersCubit>();
      final savedPosition = cubit.state.scrollPosition;
      if (savedPosition != null && savedPosition > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.jumpTo(savedPosition);
        });
      }
      _isInitialized = true;
    }
  }

  String _formatLastActive(DateTime? lastActive) {
    if (lastActive == null) return '';
    final now = DateTime.now();
    final difference = now.difference(lastActive);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return DateFormat('MMM d').format(lastActive);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsersCubit, UsersState>(
      builder: (context, state) {
        if (state.isLoading && state.users.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null && state.users.isEmpty) {
          return AppErrorWidget(
            message: state.error!,
            onRetry: () => context.read<UsersCubit>().loadUsers(),
            icon: Icons.people_outline,
          );
        }

        if (state.users.isEmpty) {
          return const AppEmptyStateWidget(
            message: AppStrings.noUsers,
            icon: Icons.people_outline,
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.zero,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: state.users.length,
          itemBuilder: (context, index) {
            final user = state.users[index];
            final isSelected = _selectedUserId == user.id;
            return _UserListItem(
              user: user,
              isSelected: isSelected,
              formatLastActive: _formatLastActive,
              onTap: () {
                setState(() => _selectedUserId = user.id);
                widget.onUserTap(user.id, user.name);
              },
            );
          },
        );
      },
    );
  }
}

class _UserListItem extends StatelessWidget {
  final UserEntity user;
  final bool isSelected;
  final String Function(DateTime?) formatLastActive;
  final VoidCallback onTap;

  const _UserListItem({
    required this.user,
    required this.isSelected,
    required this.formatLastActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isSelected ? AppColors.backgroundTertiary : AppColors.background,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar with gradient
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                  colors: AppColors.avatarGradientBlue,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      user.initial,
                    style: AppTextStyles.avatarInitial,
                    ),
                  ),
                ),
                // Online indicator (green circle in bottom right)
                if (user.status == UserStatus.online)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.online,
                        border: Border.all(
                          color: AppColors.textWhite,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: AppTextStyles.userName,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.status == UserStatus.online
                        ? AppStrings.online
                        : formatLastActive(user.lastActive),
                    style: AppTextStyles.statusText,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
