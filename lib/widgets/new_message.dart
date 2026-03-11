import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// ─── Pixel Smiley Face Painter ────────────────────────────────────────────────
class _PixelSmilePainter extends CustomPainter {
  final Color color;
  const _PixelSmilePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..style = PaintingStyle.fill;
    // 11×11 pixel smiley
    const grid = [
      [0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0],
      [0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0],
      [0, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0],
      [0, 1, 1, 0, 0, 1, 0, 0, 1, 1, 0],
      [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
      [0, 1, 1, 0, 0, 0, 0, 0, 1, 1, 0],
      [0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0],
      [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
      [0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0],
      [0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0],
    ];
    // eye pixels (col 3&4, col 7&8 at row 2-3) → darker shade
    const eyeRows = {2, 3};
    const eyeColsLeft = {3, 4};
    const eyeColsRight = {6, 7};

    final ps = size.width / grid[0].length;
    for (int r = 0; r < grid.length; r++) {
      for (int c = 0; c < grid[r].length; c++) {
        if (grid[r][c] == 0) continue;
        final isEye = eyeRows.contains(r) &&
            (eyeColsLeft.contains(c) || eyeColsRight.contains(c));
        p.color = isEye
            ? HSLColor.fromColor(color)
                .withLightness(
                    (HSLColor.fromColor(color).lightness - 0.25).clamp(0, 1))
                .toColor()
            : color;
        canvas.drawRect(
          Rect.fromLTWH(c * ps, r * ps, ps - 0.4, ps - 0.4),
          p,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Chevron ">" Send Painter ─────────────────────────────────────────────────
class _ChevronSendPainter extends CustomPainter {
  final Color color;
  const _ChevronSendPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.22
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter;

    final midY = size.height / 2;
    final tipX = size.width * 0.78;
    final leftX = size.width * 0.18;
    final topY = size.height * 0.14;
    final botY = size.height * 0.86;

    final path = Path()
      ..moveTo(leftX, topY)
      ..lineTo(tipX, midY)
      ..lineTo(leftX, botY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── NewMessage ───────────────────────────────────────────────────────────────
class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();
  bool _showEmojiPicker = false;

  // TODO: เปลี่ยน emoji list เป็น custom stickers/icons ที่ต้องการ
  static const List<String> _emojiList = [
    '😊',
    '😂',
    '❤️',
    '😍',
    '🥺',
    '😭',
    '✨',
    '🔥',
    '👍',
    '🙏',
    '💕',
    '😩',
    '🥰',
    '😘',
    '💀',
    '😅',
    '🤣',
    '😆',
    '🎉',
    '💯',
    '🤔',
    '😒',
    '😔',
    '🌸',
    '🐱',
    '🐰',
    '🍓',
    '🌈',
    '⭐',
    '💖',
    '🫶',
    '🥳',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _onEmojiTap(String emoji) {
    final pos = _messageController.selection.baseOffset;
    final text = _messageController.text;
    final newText = pos < 0
        ? text + emoji
        : text.substring(0, pos) + emoji + text.substring(pos);
    _messageController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
          offset: (pos < 0 ? text.length : pos) + emoji.length),
    );
  }

  void _submitMessage() async {
    final enteredMessage = _messageController.text;
    if (enteredMessage.trim().isEmpty) return;

    setState(() => _showEmojiPicker = false);
    FocusScope.of(context).unfocus();
    _messageController.clear();

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userDocSnap = await userDocRef.get();

      String username;
      String userImage;

      if (userDocSnap.exists && userDocSnap.data() != null) {
        final data = userDocSnap.data()!;
        final storedUsername = data['username'] as String?;
        final isEmail = storedUsername != null && storedUsername.contains('@');

        if (storedUsername != null && storedUsername.isNotEmpty && !isEmail) {
          username = storedUsername;
        } else {
          username = user.displayName ??
              (user.email != null ? user.email!.split('@')[0] : 'Anonymous');
          await userDocRef.update({'username': username});
        }
        userImage = (data['image_url'] as String?) ?? user.photoURL ?? '';
      } else {
        username = user.displayName ??
            (user.email != null ? user.email!.split('@')[0] : 'Anonymous');
        userImage = user.photoURL ?? '';
        await userDocRef.set({
          'username': username,
          'email': user.email ?? '',
          'image_url': userImage,
        });
      }

      await FirebaseFirestore.instance.collection('chat').add({
        'text': enteredMessage,
        'createdAt': Timestamp.now(),
        'userId': user.uid,
        'username': username,
        'userImage': userImage,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ส่งข้อความไม่สำเร็จ: $e'),
            backgroundColor: const Color(0xFFE8849C),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const pinkBar = Color(0xFFF5C0D0);
    const pinkMain = Color(0xFFE8849C);
    const pinkDark = Color(0xFFD4708A);
    const pinkDeep = Color(0xFFB84060);
    const textDark = Color(0xFF6A2840);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Top border ─────────────────────────────────────────────────────
        Container(height: 1.5, color: pinkDark.withOpacity(0.25)),

        // ── Input bar ──────────────────────────────────────────────────────
        Container(
          color: pinkBar,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Emoji button: pixel smiley face ──────────────────────
              GestureDetector(
                onTap: () {
                  setState(() => _showEmojiPicker = !_showEmojiPicker);
                  if (!_showEmojiPicker) FocusScope.of(context).unfocus();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _showEmojiPicker
                        ? pinkDeep.withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: CustomPaint(
                      size: const Size(28, 28),
                      painter: _PixelSmilePainter(
                        color: _showEmojiPicker ? pinkDeep : pinkMain,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 4),

              // ── Pill input ────────────────────────────────────────────
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.88),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: pinkDark.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: pinkDeep.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _messageController,
                    textCapitalization: TextCapitalization.sentences,
                    autocorrect: true,
                    enableSuggestions: true,
                    style: const TextStyle(color: textDark, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(
                        color: pinkDark.withOpacity(0.45),
                        fontSize: 13,
                      ),
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onTap: () => setState(() => _showEmojiPicker = false),
                    onSubmitted: (_) => _submitMessage(),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // ── Send button: clean chevron ">" no background ──────────
              GestureDetector(
                onTap: _submitMessage,
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: CustomPaint(
                      size: const Size(22, 26),
                      painter: _ChevronSendPainter(color: pinkDeep),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Emoji picker panel ─────────────────────────────────────────────
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          child: _showEmojiPicker
              ? Container(
                  color: const Color(0xFFFFF0F3),
                  child: Column(
                    children: [
                      Container(height: 1, color: pinkDark.withOpacity(0.2)),
                      SizedBox(
                        height: 200,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 8,
                            mainAxisSpacing: 4,
                            crossAxisSpacing: 4,
                          ),
                          itemCount: _emojiList.length,
                          itemBuilder: (ctx, i) => GestureDetector(
                            onTap: () => _onEmojiTap(_emojiList[i]),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: pinkDark.withOpacity(0.15)),
                              ),
                              child: Center(
                                child: Text(_emojiList[i],
                                    style: const TextStyle(fontSize: 18)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
