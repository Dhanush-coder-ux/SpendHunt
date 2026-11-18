import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/ai_message.dart';
import '../../../core/providers/ai_assistant_provider.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../../../shared/widgets/fin_animated_icon.dart';
import '../../../shared/widgets/spendhunt_ai_orb.dart';

class AIAssistantScreen extends ConsumerStatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  ConsumerState<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends ConsumerState<AIAssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _suggestedPrompts = [
    'Analyse my spending',
    'How much can I save this month?',
    'Show my biggest expenses',
    'Can I afford a purchase?',
    'Analyse my financial health',
    'Predict my monthly expenses',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    _textController.clear();
    ref.read(aiAssistantProvider.notifier).sendMessage(text.trim());
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiAssistantProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= AppConstants.tabletBreakpoint;

    // Trigger scroll when new messages arrive
    ref.listen(aiAssistantProvider, (prev, next) {
      if (prev?.messages.length != next.messages.length || prev?.isTyping != next.isTyping) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Row(
          children: [
            SpendHuntAIOrb(size: 32, showGlow: true),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SpendHunt AI',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Online Intelligence • Active',
                  style: TextStyle(fontSize: 10.5, color: AppColors.success),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _showIntelligenceMenu(context),
            icon: const Icon(LucideIcons.barChart, size: 19),
            tooltip: 'Intelligence Modules',
          ),
          IconButton(
            onPressed: () async {
              final confirmed = await ConfirmationDialog.show(
                context,
                title: 'Clear Conversation',
                message: 'Do you want to reset your AI conversation history?',
                confirmLabel: 'Clear',
                isDestructive: false,
              );
              if (confirmed == true) {
                ref.read(aiAssistantProvider.notifier).clearConversation();
              }
            },
            icon: const Icon(LucideIcons.rotateCcw, size: 19),
            tooltip: 'Reset Chat',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: Column(
              children: [
                // Quick intelligence pills bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildIntelligencePill(
                          context,
                          label: 'Spending Analysis',
                          icon: LucideIcons.pieChart,
                          onTap: () => context.push('/ai/spending-analysis'),
                        ),
                        const SizedBox(width: 8),
                        _buildIntelligencePill(
                          context,
                          label: 'Future Forecast',
                          icon: LucideIcons.trendingUp,
                          onTap: () => context.push('/ai/forecast'),
                        ),
                        const SizedBox(width: 8),
                        _buildIntelligencePill(
                          context,
                          label: 'Health Score (84)',
                          icon: LucideIcons.shieldCheck,
                          onTap: () => context.push('/ai/health-score'),
                        ),
                      ],
                    ),
                  ),
                ),

                // Chat Messages List
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 24 : 16,
                      vertical: 16,
                    ),
                    itemCount: aiState.messages.length + (aiState.isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == aiState.messages.length && aiState.isTyping) {
                        return _buildTypingIndicator(isDark);
                      }

                      final msg = aiState.messages[index];
                      final isUser = msg.sender == MessageSender.user;

                      return Column(
                        crossAxisAlignment:
                            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isUser) ...[
                                const SpendHuntAIOrb(size: 28),
                                const SizedBox(width: 10),
                              ],
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 13,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isUser
                                        ? AppColors.deepForest
                                        : (isDark
                                            ? AppColors.surfaceDark
                                            : AppColors.surfaceLight),
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(18),
                                      topRight: const Radius.circular(18),
                                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                                      bottomRight: Radius.circular(isUser ? 4 : 18),
                                    ),
                                    border: isUser
                                        ? null
                                        : Border.all(
                                            color: isDark
                                                ? AppColors.borderDark
                                                : AppColors.borderLight,
                                          ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: isDark ? 0.15 : 0.03,
                                        ),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    msg.content,
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1.45,
                                      color: isUser
                                          ? Colors.white
                                          : (isDark
                                              ? AppColors.textPrimaryDark
                                              : AppColors.textPrimaryLight),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 4,
                              bottom: 12,
                              left: isUser ? 0 : 42,
                              right: isUser ? 8 : 0,
                            ),
                            child: Text(
                              DateFormatter.formatTime(msg.timestamp),
                              style: TextStyle(
                                fontSize: 10.5,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ),

                          // Suggested follow-ups from this message
                          if (!isUser && msg.followUps != null && msg.followUps!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 42, bottom: 14),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: msg.followUps!.map((f) {
                                  return InkWell(
                                    onTap: () => _sendMessage(f),
                                    borderRadius: BorderRadius.circular(14),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 11,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppColors.surfaceSecondaryDark
                                            : AppColors.surfaceSecondaryLight,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: isDark
                                              ? AppColors.borderDark
                                              : AppColors.borderLight,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            LucideIcons.cornerDownRight,
                                            size: 11,
                                            color: AppColors.sage,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            f,
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w500,
                                              color: isDark
                                                  ? AppColors.textPrimaryDark
                                                  : AppColors.deepForest,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),

                // Suggested Prompts Row (if chat has 1 welcome message)
                if (aiState.messages.length <= 1)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _suggestedPrompts.map((prompt) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ActionChip(
                              label: Text(
                                prompt,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                              onPressed: () => _sendMessage(prompt),
                              backgroundColor: isDark
                                  ? AppColors.surfaceDark
                                  : AppColors.surfaceLight,
                              side: BorderSide(
                                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                              ),
                              avatar: const Icon(LucideIcons.sparkles, size: 13, color: AppColors.warmBronze),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                // Bottom Input Field
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 24 : 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceSecondaryDark
                                : AppColors.surfaceSecondaryLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: TextField(
                            controller: _textController,
                            onSubmitted: _sendMessage,
                            style: const TextStyle(fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: 'Ask about cash flow, budgets, or predictions...',
                              hintStyle: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: AppColors.deepForest,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(LucideIcons.arrowUp, color: Colors.white, size: 20),
                          onPressed: () => _sendMessage(_textController.text),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 42, bottom: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SpendHuntAIOrb(
              size: 20,
              state: SpendHuntAIState.thinking,
            ),
            SizedBox(width: 8),
            Text(
              'SpendHunt analyzing records...',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntelligencePill(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.deepForest.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            FinAnimatedIcon(icon: icon, size: 14, color: AppColors.deepForest),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.deepForest),
            ),
          ],
        ),
      ),
    );
  }

  void _showIntelligenceMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('AI Intelligence Modules', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(LucideIcons.pieChart, color: AppColors.deepForest),
                title: const Text('AI Spending Analysis'),
                subtitle: const Text('Top expense drivers, anomalies and savings opportunities'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/ai/spending-analysis');
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.trendingUp, color: AppColors.warmBronze),
                title: const Text('AI Financial Forecast'),
                subtitle: const Text('Month-end projections and what-if scenario simulations'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/ai/forecast');
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.shieldCheck, color: AppColors.success),
                title: const Text('Financial Health Score'),
                subtitle: const Text('Holistic metric on savings, debt ratio, and discipline'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/ai/health-score');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
