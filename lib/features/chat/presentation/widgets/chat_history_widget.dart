import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubit/chat_history_cubit.dart';
import '../cubit/chat_history_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_strings.dart';
import '../../../../core/widgets/error_widget.dart';

class ChatHistoryWidget extends StatefulWidget {
  final ScrollController? scrollController;
  final Function(String userId, String userName) onSessionTap;

  const ChatHistoryWidget({
    super.key,
    this.scrollController,
    required this.onSessionTap,
  });

  @override
  State<ChatHistoryWidget> createState() => _ChatHistoryWidgetState();
}

class _ChatHistoryWidgetState extends State<ChatHistoryWidget> {
  late ScrollController _scrollController;
  bool _isInitialized = false;

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
    final cubit = context.read<ChatHistoryCubit>();
    cubit.saveScrollPosition(_scrollController.offset);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final cubit = context.read<ChatHistoryCubit>();
      final savedPosition = cubit.state.scrollPosition;
      if (savedPosition != null && savedPosition > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.jumpTo(savedPosition);
        });
      }
      _isInitialized = true;
    }
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return AppStrings.justNow;
    } else if (difference.inMinutes < 60) {
      return AppStrings.formatMinutesAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return AppStrings.formatHoursAgo(difference.inHours);
    } else if (difference.inDays == 1) {
      return AppStrings.yesterday;
    } else if (difference.inDays < 7) {
      return AppStrings.formatDaysAgo(difference.inDays);
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatHistoryCubit, ChatHistoryState>(
      builder: (context, state) {
        if (state.isLoading && state.sessions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null && state.sessions.isEmpty) {
          return AppErrorWidget(
            message: state.error!,
            onRetry: () => context.read<ChatHistoryCubit>().loadChatSessions(),
            icon: Icons.chat_bubble_outline,
          );
        }

        if (state.sessions.isEmpty) {
          return const AppEmptyStateWidget(
            message: AppStrings.noChatHistory,
            icon: Icons.chat_bubble_outline,
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.zero,
          itemCount: state.sessions.length,
          itemBuilder: (context, index) {
            final session = state.sessions[index];
            return _ChatSessionItem(
              session: session,
              formatTime: _formatTime,
              onTap: () => widget.onSessionTap(session.userId, session.userName),
            );
          },
        );
      },
    );
  }
}

class _ChatSessionItem extends StatelessWidget {
  final dynamic session;
  final String Function(DateTime?) formatTime;
  final VoidCallback onTap;

  const _ChatSessionItem({
    required this.session,
    required this.formatTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Avatar with solid color
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.chatHistoryAvatar,
                ),
                child: Center(
                  child: Text(
                    session.userInitial,
                    style: AppTextStyles.avatarInitial,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.userName,
                    style: AppTextStyles.userName,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    session.lastMessage ?? AppStrings.lastMessagePlaceholder,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.lastMessage,
                  ),
                  ],
                ),
              ),
              // Timestamp and unread badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (session.lastMessageTime != null)
                    Text(
                      formatTime(session.lastMessageTime),
                      style: AppTextStyles.timestampSmall,
                    ),
                  if (session.unreadCount > 0) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        session.unreadCount > 99 ? '99+' : '${session.unreadCount}',
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.textWhite),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

