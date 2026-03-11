import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  String _formatTime(Timestamp ts) {
    final dt = ts.toDate().toLocal();
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  bool _isDifferentMinute(Timestamp a, Timestamp b) {
    final da = a.toDate().toLocal();
    final db = b.toDate().toLocal();
    return da.hour != db.hour || da.minute != db.minute;
  }

  @override
  Widget build(BuildContext context) {
    const pinkDeep = Color(0xFFB84060);
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFE8849C)),
          );
        }

        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFFD4708A).withOpacity(0.4)),
                  ),
                  child: const Text(
                    '♥  No messages yet  ♥',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFC45878),
                      fontSize: 13,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Say hello! (＾▽＾)',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: const Color(0xFFD4708A).withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        }

        if (chatSnapshots.hasError) {
          return const Center(
              child: Text('Something went wrong...',
                  style: TextStyle(color: Color(0xFFE8849C))));
        }

        final loadedMessages = chatSnapshots.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 16, left: 4, right: 4, top: 8),
          reverse: true,
          itemCount: loadedMessages.length,
          itemBuilder: (ctx, index) {
            final chatMessage = loadedMessages[index].data();
            final nextChatMessage = index + 1 < loadedMessages.length
                ? loadedMessages[index + 1].data()
                : null;

            final currentMessageUserId = chatMessage['userId'];
            final nextMessageUserId =
                nextChatMessage != null ? nextChatMessage['userId'] : null;
            final nextUserIsSame = nextMessageUserId == currentMessageUserId;

            final currentTs = chatMessage['createdAt'] as Timestamp?;
            final nextTs = nextChatMessage != null
                ? nextChatMessage['createdAt'] as Timestamp?
                : null;

            final bool showTimeSeparator = currentTs != null &&
                (nextTs == null || _isDifferentMinute(currentTs, nextTs));

            final Widget bubble = nextUserIsSame
                ? MessageBubble.next(
                    message: chatMessage['text'],
                    isMe: authenticatedUser.uid == currentMessageUserId,
                  )
                : MessageBubble.first(
                    userImage: chatMessage['userImage'],
                    username: chatMessage['username'],
                    message: chatMessage['text'],
                    isMe: authenticatedUser.uid == currentMessageUserId,
                  );

            if (!showTimeSeparator) return bubble;

            // ── Time separator ─────────────────────────────────────────
            final timeSeparator = Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  _formatTime(currentTs!),
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: pinkDeep.withOpacity(0.55),
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            );

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [bubble, timeSeparator],
            );
          },
        );
      },
    );
  }
}
