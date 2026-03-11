import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble.first({
    super.key,
    required this.userImage,
    required this.username,
    required this.message,
    required this.isMe,
  }) : isFirstInSequence = true;

  const MessageBubble.next({
    super.key,
    required this.message,
    required this.isMe,
  })  : isFirstInSequence = false,
        userImage = null,
        username = null;

  final bool isFirstInSequence;
  final String? userImage;
  final String? username;
  final String message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    // Palette from the reference image
    const bubbleMe = Color(0xFFC45878); // dark rose — my messages
    const bubbleOther = Color(0xFFF5C8D4); // soft pink — other messages
    const pinkDark = Color(0xFFD4708A);
    const pinkDeep = Color(0xFFB84060);
    const pinkLight = Color(0xFFFFF0F3);
    const textMe = Colors.white;
    const textOther = Color(0xFF6A2840);
    const usernameColor = Color(0xFF9A3858);

    // ── Pixel square avatar ────────────────────────────────────────────────
    Widget avatarBox(String? url) => Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            border: Border.all(color: pinkDeep, width: 2),
            color: pinkLight,
          ),
          child: url != null && url.isNotEmpty
              ? Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.person,
                    color: pinkDark,
                    size: 20,
                  ),
                )
              : Icon(Icons.person, color: pinkDark, size: 20),
        );

    return Padding(
      padding: EdgeInsets.only(
        left: isMe ? 60 : 8,
        right: isMe ? 8 : 60,
        top: isFirstInSequence ? 8 : 2,
        bottom: 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // ── Avatar LEFT ───────────────────────────────────────────────────
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(right: 6, top: 2),
              child: isFirstInSequence
                  ? avatarBox(userImage)
                  : const SizedBox(width: 36),
            ),

          // ── Content column ────────────────────────────────────────────────
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Username
                if (isFirstInSequence && username != null)
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: 3, left: 4, right: 4),
                    child: Text(
                      username!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w800,
                        color: usernameColor,
                        fontSize: 11,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),

                // ── Pill-shaped bubble ────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: isMe ? bubbleMe : bubbleOther,
                    // Very rounded pill shape — matching reference image
                    borderRadius: BorderRadius.only(
                      topLeft: !isMe && isFirstInSequence
                          ? const Radius.circular(4)
                          : const Radius.circular(20),
                      topRight: isMe && isFirstInSequence
                          ? const Radius.circular(4)
                          : const Radius.circular(20),
                      bottomLeft: const Radius.circular(20),
                      bottomRight: const Radius.circular(20),
                    ),
                    // Subtle shadow
                    boxShadow: [
                      BoxShadow(
                        color: pinkDeep.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(maxWidth: 230),
                  padding:
                      const EdgeInsets.symmetric(vertical: 9, horizontal: 15),
                  child: Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      color: isMe ? textMe : textOther,
                    ),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),

          // ── Avatar RIGHT ──────────────────────────────────────────────────
          if (isMe)
            Padding(
              padding: const EdgeInsets.only(left: 6, top: 2),
              child: isFirstInSequence
                  ? avatarBox(userImage)
                  : const SizedBox(width: 36),
            ),
        ],
      ),
    );
  }
}
