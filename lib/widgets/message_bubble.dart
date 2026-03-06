import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/message.dart';
import '../theme/app_theme.dart';
import 'droid_logo.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool showCopyButton;

  const MessageBubble({
    super.key,
    required this.message,
    this.showCopyButton = true,
  });

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: message.content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              message.isUser ? 'Message copied' : 'Response copied',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUser = message.isUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth > 800 ? 800.0 : double.infinity;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: screenWidth > 600 ? 48 : 16,
        right: screenWidth > 600 ? 48 : 16,
        top: 2,
        bottom: 2,
      ),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(right: 12, top: 4),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    '🤖',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          
          // Message content
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Role label
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    isUser ? 'You' : 'ChatBoteo',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                ),
                
                // Message bubble
                GestureDetector(
                  onLongPress: showCopyButton ? () => _copyToClipboard(context) : null,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: maxWidth * 0.8,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isUser
                          ? (isDark ? const Color(0xFF343541) : const Color(0xFFE9E9EB))
                          : (isDark ? const Color(0xFF343541) : const Color(0xFFF7F7F8)),
                      borderRadius: BorderRadius.circular(12),
                      border: isDark
                          ? Border.all(color: Colors.white.withValues(alpha: 0.05))
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Message text
                        SelectableText(
                          message.content,
                          style: TextStyle(
                            color: isUser
                                ? (isDark ? Colors.white : Colors.black87)
                                : (isDark ? Colors.white : Colors.black87),
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        
                        // Copy button
                        if (showCopyButton) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () => _copyToClipboard(context),
                                borderRadius: BorderRadius.circular(6),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.copy_rounded,
                                        size: 14,
                                        color: isUser
                                            ? (isDark ? Colors.white54 : Colors.black45)
                                            : (isDark ? Colors.white54 : Colors.black45),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Copy',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isUser
                                              ? (isDark ? Colors.white54 : Colors.black45)
                                              : (isDark ? Colors.white54 : Colors.black45),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // User avatar
          if (isUser)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 4),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF10A37F) : const Color(0xFF10A37F),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
