import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_strings.dart';
import '../../../../core/widgets/error_widget.dart';
import '../cubit/chat_screen_cubit.dart';
import '../cubit/chat_screen_state.dart';
import '../../domain/entities/message_entity.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/usecases/get_messages_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/update_chat_session_usecase.dart';
import '../../domain/usecases/fetch_receiver_message_usecase.dart';
import '../../domain/usecases/save_receiver_message_usecase.dart';
import '../../domain/usecases/fetch_word_meaning_usecase.dart';

class ChatScreen extends StatelessWidget {
  final String userId;
  final String userName;

  const ChatScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
        return BlocProvider(
          create: (context) => ChatScreenCubit(
            getIt<GetMessagesUseCase>(),
            getIt<SendMessageUseCase>(),
            getIt<UpdateChatSessionUseCase>(),
            getIt<FetchReceiverMessageUseCase>(),
            getIt<SaveReceiverMessageUseCase>(),
            userId,
            userName,
          ),
          child: _ChatScreenView(userName: userName),
        );
  }
}

class _ChatScreenView extends StatefulWidget {
  final String userName;

  const _ChatScreenView({required this.userName});

  @override
  State<_ChatScreenView> createState() => _ChatScreenViewState();
}

class _ChatScreenViewState extends State<_ChatScreenView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      // Scroll to the end (newest messages at bottom)
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final content = _messageController.text;
    if (content.trim().isNotEmpty) {
      context.read<ChatScreenCubit>().sendMessage(content);
      _messageController.clear();
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    }
  }

      Future<void> _showWordMeaning(String word) async {
    if (word.isEmpty) return;
    if (!mounted) return;
    final currentContext = context;
    
    // Show bottom sheet with loading state that will update in place
    showModalBottomSheet(
      context: currentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => _WordMeaningBottomSheet(
        word: word,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 1,
        shadowColor: Colors.transparent,
        surfaceTintColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => GoRouter.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
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
                  widget.userName.isNotEmpty
                      ? widget.userName[0].toUpperCase()
                      : '?',
                  style: AppTextStyles.avatarInitial,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.userName,
                  style: AppTextStyles.userName,
                ),
                Text(
                  AppStrings.online,
                  style: AppTextStyles.statusText,
                ),
              ],
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: BlocBuilder<ChatScreenCubit, ChatScreenState>(
        builder: (context, state) {
          if (state.isLoading && state.messages.isEmpty) {
            return Skeletonizer(
              enabled: true,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: 5,
                itemBuilder: (context, index) {
                  // Alternate between sender and receiver skeletons
                  final isSender = index % 2 == 1;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: isSender
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isSender) ...[
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Column(
                            crossAxisAlignment: isSender
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.58,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isSender
                                      ? AppColors.senderBubble
                                      : AppColors.receiverBubble,
                                  borderRadius: BorderRadius.only(
                                    topLeft: isSender
                                        ? const Radius.circular(16)
                                        : const Radius.circular(4),
                                    topRight: isSender
                                        ? const Radius.circular(4)
                                        : const Radius.circular(16),
                                    bottomLeft: const Radius.circular(16),
                                    bottomRight: const Radius.circular(16),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Lorem ipsum dolor sit amet',
                                      style: isSender
                                          ? AppTextStyles.messageTextSender
                                          : AppTextStyles.messageTextReceiver,
                                    ),
                                    if (index % 3 == 0)
                                      Text(
                                        'consectetur adipiscing elit',
                                        style: isSender
                                            ? AppTextStyles.messageTextSender
                                            : AppTextStyles.messageTextReceiver,
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: isSender ? 0 : 4,
                                  right: isSender ? 4 : 0,
                                ),
                                child: Text(
                                  '10:30 AM',
                                  style: AppTextStyles.timestamp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSender) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            );
          }

          if (state.error != null && state.messages.isEmpty) {
            return AppErrorWidget(
              message: state.error!,
              onRetry: () => context.read<ChatScreenCubit>().loadMessages(),
              icon: Icons.message_outlined,
            );
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (state.messages.isNotEmpty && _scrollController.hasClients) {
              _scrollToBottom();
            }
          });

          return Column(
            children: [
              Expanded(
                child: state.messages.isEmpty
                    ? const Center(
                        child: Text(
                          'No messages yet.\nStart a conversation!',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        reverse: false,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          if (index >= state.messages.length) {
                            return const SizedBox.shrink();
                          }
                          
                          final message = state.messages[index];
                          
                          // Skip read receipt messages (they're invisible markers)
                          if (message.id.startsWith('read_')) {
                            return const SizedBox.shrink();
                          }
                          
                          // Check if previous message (visually above) is from same sender (for grouping)
                          // Messages are sorted oldest to newest: index 0 = oldest (top), index n = newest (bottom)
                          // We show avatar if the previous message (index - 1, visually above) is from different sender
                          final prevIndex = index - 1;
                          final prevMessage = prevIndex >= 0 
                              ? state.messages[prevIndex] 
                              : null;
                          final showAvatar = prevMessage == null || prevMessage.type != message.type;
                          
                          return _MessageBubble(
                            message: message,
                            userName: widget.userName,
                            showAvatar: showAvatar,
                            onWordTap: _showWordMeaning,
                          );
                        },
                      ),
              ),
              if (state.isSending)
                const LinearProgressIndicator(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: _MessageInputField(
                  controller: _messageController,
                  onSend: _sendMessage,
                  isSending: state.isSending,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final String userName;
  final bool showAvatar;
  final Function(String) onWordTap;

  const _MessageBubble({
    required this.message,
    required this.userName,
    required this.showAvatar,
    required this.onWordTap,
  });

  String _formatTime(DateTime? timestamp) {
    if (timestamp == null) return '';
    return DateFormat('h:mm a').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    final isSender = message.type == MessageType.sender;
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';
    final senderInitial = 'Y'; // You

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isSender) ...[
            if (showAvatar)
              Container(
                width: 32,
                height: 32,
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
                    initial,
                    style: AppTextStyles.avatarInitial.copyWith(fontSize: 14),
                  ),
                ),
              )
            else
              const SizedBox(width: 32),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.58,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSender
                          ? AppColors.senderBubble
                          : AppColors.receiverBubble,
                      borderRadius: BorderRadius.only(
                        topLeft: isSender ? const Radius.circular(16) : const Radius.circular(4),
                        topRight: isSender ? const Radius.circular(4) : const Radius.circular(16),
                        bottomLeft: const Radius.circular(16),
                        bottomRight: const Radius.circular(16),
                      ),
                    ),
                    child: _SelectableTextWithWordTap(
                      text: message.content,
                      style: isSender
                          ? AppTextStyles.messageTextSender
                          : AppTextStyles.messageTextReceiver,
                      onWordTap: onWordTap,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: EdgeInsets.only(
                    left: isSender ? 0 : 4,
                    right: isSender ? 4 : 0,
                  ),
                  child: Text(
                    _formatTime(message.timestamp),
                    style: AppTextStyles.timestamp,
                  ),
                ),
              ],
            ),
          ),
          if (isSender) ...[
            const SizedBox(width: 8),
            if (showAvatar)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.avatarGradientPurple,
                  ),
                ),
                child: Center(
                  child: Text(
                    senderInitial,
                    style: AppTextStyles.avatarInitial.copyWith(fontSize: 14),
                  ),
                ),
              )
            else
              const SizedBox(width: 32),
          ],
        ],
      ),
    );
  }
}

class _WordMeaningBottomSheet extends StatefulWidget {
  final String word;
  final VoidCallback onClose;

  const _WordMeaningBottomSheet({
    required this.word,
    required this.onClose,
  });

  @override
  State<_WordMeaningBottomSheet> createState() => _WordMeaningBottomSheetState();
}

class _WordMeaningBottomSheetState extends State<_WordMeaningBottomSheet> {
  String? _meaning;
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWordMeaning();
  }

  Future<void> _fetchWordMeaning() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final fetchWordMeaningUseCase = getIt<FetchWordMeaningUseCase>();
      final meaning = await fetchWordMeaningUseCase(widget.word);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        if (meaning != null && meaning.isNotEmpty) {
          _meaning = meaning;
          _error = null;
        } else {
          _meaning = null;
          _error = 'No meaning found for "${widget.word}".';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _meaning = null;
        _error = 'Could not fetch word meaning. Please check your internet connection and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child:                   Text(
                    widget.word.toUpperCase(),
                    style: AppTextStyles.wordMeaningTitle,
                  ),
              ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: widget.onClose,
                      color: Colors.grey.shade600,
                    ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isLoading
                ? Skeletonizer(
                    enabled: true,
                    child: Column(
                      key: const ValueKey('loading'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.meaning,
                          style: AppTextStyles.wordMeaningLabel,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                          style: AppTextStyles.wordMeaningText,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.',
                          style: AppTextStyles.wordMeaningText,
                        ),
                      ],
                    ),
                  )
                : _error != null
                    ? Text(
                        key: const ValueKey('error'),
                        _error!,
                        style: AppTextStyles.errorText,
                      )
                    : Column(
                        key: const ValueKey('meaning'),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.meaning,
                            style: AppTextStyles.wordMeaningLabel,
                          ),
                          const SizedBox(height: 8),
                            Text(
                              _meaning!,
                              style: AppTextStyles.wordMeaningText,
                            ),
                        ],
                      ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _SelectableTextWithWordTap extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Function(String) onWordTap;

  const _SelectableTextWithWordTap({
    required this.text,
    required this.style,
    required this.onWordTap,
  });

  @override
  Widget build(BuildContext context) {
    // Match words (sequences of word characters) and preserve everything
    final wordPattern = RegExp(r'\b\w+\b');
    final textSpans = <TextSpan>[];
    int lastEnd = 0;

    // Find all word matches
    final matches = wordPattern.allMatches(text);
    
    for (final match in matches) {
      // Add text before the word (spaces, punctuation, etc.)
      if (match.start > lastEnd) {
        textSpans.add(
          TextSpan(
            text: text.substring(lastEnd, match.start),
            style: style,
          ),
        );
      }

      // Add the word with gesture recognizer
      final word = match.group(0)!;
      final recognizer = LongPressGestureRecognizer()
        ..onLongPress = () {
          onWordTap(word.toLowerCase());
        };
      
      textSpans.add(
        TextSpan(
          text: word,
          style: style,
          recognizer: recognizer,
        ),
      );

      lastEnd = match.end;
    }

    // Add remaining text after the last word
    if (lastEnd < text.length) {
      textSpans.add(
        TextSpan(
          text: text.substring(lastEnd),
          style: style,
        ),
      );
    }

    return RichText(
      text: TextSpan(children: textSpans),
      softWrap: true,
    );
  }
}

class _MessageInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isSending;

  const _MessageInputField({
    required this.controller,
    required this.onSend,
    required this.isSending,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !isSending,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: AppStrings.typeMessage,
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.backgroundSecondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: isSending ? null : onSend,
            mini: true,
            backgroundColor: AppColors.primary,
            shape: const CircleBorder(),
            child: isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.send, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}

