import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:chat_app/widgets/chat_messages.dart';
import 'package:chat_app/widgets/new_message.dart';

// ── Pixel heart for AppBar only ───────────────────────────────────────────────
class _PixelHeartPainter extends CustomPainter {
  final Color color;
  const _PixelHeartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..style = PaintingStyle.fill;
    const grid = [
      [0,1,1,0,1,1,0],
      [1,1,1,1,1,1,1],
      [1,1,1,1,1,1,1],
      [0,1,1,1,1,1,0],
      [0,0,1,1,1,0,0],
      [0,0,0,1,0,0,0],
    ];
    final ps = size.width / grid[0].length;
    for (int r = 0; r < grid.length; r++) {
      for (int c = 0; c < grid[r].length; c++) {
        if (grid[r][c] == 0) continue;
        canvas.drawRect(Rect.fromLTWH(c * ps, r * ps, ps - 0.4, ps - 0.4), p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── ChatScreen ───────────────────────────────────────────────────────────────
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void setupPushNotifications() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    fcm.subscribeToTopic('chat');
  }

  @override
  void initState() {
    super.initState();
    setupPushNotifications();
  }

  @override
  Widget build(BuildContext context) {
    const bgColor    = Color(0xFFFAD4E0); // soft solid pink — clean & flat
    const pinkAppBar = Color(0xFFF0A0B8);
    const pinkDeep   = Color(0xFFC45070);
    const textDark   = Color(0xFF6A2840);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: pinkAppBar,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(height: 2, color: pinkDeep.withOpacity(0.25)),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(
              size: const Size(22, 19),
              painter: _PixelHeartPainter(color: pinkDeep),
            ),
            const SizedBox(width: 10),
            const Text(
              'CHAT',
              style: TextStyle(
                fontFamily: 'monospace',
                color: Color(0xFF6A2840),
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 2.5,
              ),
            ),
            const SizedBox(width: 10),
            CustomPaint(
              size: const Size(22, 19),
              painter: _PixelHeartPainter(color: pinkDeep),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
            child: GestureDetector(
              onTap: () => FirebaseAuth.instance.signOut(),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: pinkAppBar,
                  border: Border.all(color: pinkDeep, width: 1.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Icon(Icons.exit_to_app, color: textDark, size: 18),
                ),
              ),
            ),
          ),
        ],
      ),
      body: const Column(
        children: [
          Expanded(child: ChatMessages()),
          NewMessage(),
        ],
      ),
    );
  }
}