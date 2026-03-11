import 'dart:io';

import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart'; // ← ใช้ kIsWeb
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final _firebase = FirebaseAuth.instance;

// ─── Pixel Dashed Border Painter ─────────────────────────────────────────────
class PixelDashBorderPainter extends CustomPainter {
  final Color color;
  final double squareSize;
  final double gap;

  const PixelDashBorderPainter({
    required this.color,
    this.squareSize = 5,
    this.gap = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final step = squareSize + gap;

    for (double x = 0; x < size.width; x += step) {
      canvas.drawRect(Rect.fromLTWH(x, 0, squareSize, squareSize), paint);
      canvas.drawRect(
          Rect.fromLTWH(x, size.height - squareSize, squareSize, squareSize),
          paint);
    }
    for (double y = step; y < size.height - squareSize; y += step) {
      canvas.drawRect(Rect.fromLTWH(0, y, squareSize, squareSize), paint);
      canvas.drawRect(
          Rect.fromLTWH(size.width - squareSize, y, squareSize, squareSize),
          paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Pixel Chat Bubble Painter ────────────────────────────────────────────────
class PixelChatBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const pink = Color(0xFFEF9BB0);
    const lightPink = Color(0xFFF5C0CE);
    const darkPink = Color(0xFFD4708A);
    const dotColor = Color(0xFFBB5575);

    final p = Paint()..style = PaintingStyle.fill;
    const ps = 7.0;

    final grid = [
      [0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0],
      [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0],
      [0, 1, 1, 2, 1, 1, 1, 1, 1, 1, 3, 1, 1, 0],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [1, 1, 1, 4, 1, 1, 4, 1, 1, 4, 1, 1, 1, 1],
      [1, 1, 1, 4, 1, 1, 4, 1, 1, 4, 1, 1, 1, 1],
      [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
      [0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0],
      [0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0],
      [0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    ];

    final totalW = grid[0].length * ps;
    final totalH = grid.length * ps;
    final offsetX = (size.width - totalW) / 2;
    final offsetY = (size.height - totalH) / 2;

    for (int row = 0; row < grid.length; row++) {
      for (int col = 0; col < grid[row].length; col++) {
        final v = grid[row][col];
        if (v == 0) continue;
        p.color = switch (v) {
          2 => lightPink,
          3 => darkPink,
          4 => dotColor,
          _ => pink,
        };
        canvas.drawRect(
          Rect.fromLTWH(offsetX + col * ps, offsetY + row * ps, ps, ps),
          p,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Pink Pixel Input Field ───────────────────────────────────────────────────
class PinkPixelInputField extends StatelessWidget {
  final String label;
  final bool obscure;
  final TextInputType keyboardType;
  final bool autocorrect;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;

  const PinkPixelInputField({
    super.key,
    required this.label,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.autocorrect = true,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFD4708A), fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFE8A0B0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFD4708A), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFFF6B8A), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFFF6B8A), width: 2),
        ),
      ),
      style: const TextStyle(color: Color(0xFF5A3040), fontSize: 14),
      obscureText: obscure,
      keyboardType: keyboardType,
      autocorrect: autocorrect,
      textCapitalization: textCapitalization,
      validator: validator,
      onSaved: onSaved,
    );
  }
}

// ─── Auth Screen ──────────────────────────────────────────────────────────────
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();

  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUsername = '';
  File? _selectedImage;
  var _isAuthenticating = false;

  // ── Email / Password ────────────────────────────────────────────────────────
  void _submit() async {
    final isValid = _form.currentState!.validate();
    if (!isValid || !_isLogin && _selectedImage == null) return;
    _form.currentState!.save();
    try {
      setState(() => _isAuthenticating = true);
      if (_isLogin) {
        await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredentials.user!.uid}.jpg');
        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': _enteredUsername,
          'email': _enteredEmail,
          'image_url': imageUrl,
        });
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error.message ?? 'Authentication failed.'),
        backgroundColor: const Color(0xFFE8849C),
      ));
      setState(() => _isAuthenticating = false);
    }
  }

  // ── Google Login ────────────────────────────────────────────────────────────
  Future<void> _signInWithGoogle() async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        // ✅ Web: ใช้ signInWithPopup
        final googleProvider = GoogleAuthProvider();
        userCredential =
            await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        // ✅ Mobile: ใช้ GoogleSignIn
        final GoogleSignIn googleSignIn = GoogleSignIn(
          clientId:
              '1069469230887-lmvh0squj57hodcnul6iviee8qho6lpb.apps.googleusercontent.com',
        );
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) return;

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
      }

      await _saveUserIfNotExists(userCredential.user!);
    } catch (error) {
      if (!mounted) return;
      _showError('ล็อคอินด้วย Google ล้มเหลว: $error');
    }
  }

  // ── Microsoft Login ─────────────────────────────────────────────────────────
  Future<void> _signInWithMicrosoft() async {
    try {
      final microsoftProvider = OAuthProvider('microsoft.com')
        ..addScope('email')
        ..addScope('openid')
        ..addScope('profile')
        ..setCustomParameters({'tenant': 'common'});

      UserCredential userCredential;

      if (kIsWeb) {
        // ✅ Web: ใช้ signInWithPopup
        userCredential =
            await FirebaseAuth.instance.signInWithPopup(microsoftProvider);
      } else {
        // ✅ Mobile: ใช้ signInWithProvider
        userCredential =
            await FirebaseAuth.instance.signInWithProvider(microsoftProvider);
      }

      await _saveUserIfNotExists(userCredential.user!);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      _showError('ล็อคอินด้วย Microsoft ล้มเหลว: ${error.message}');
    } catch (error) {
      if (!mounted) return;
      _showError('ล็อคอินด้วย Microsoft ล้มเหลว: $error');
    }
  }

  // ── Helper: บันทึก user ถ้ายังไม่มีใน Firestore ────────────────────────────
  Future<void> _saveUserIfNotExists(User user) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!userDoc.exists) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'username': user.displayName ?? user.email?.split('@')[0] ?? 'User',
        'email': user.email ?? '',
        'image_url': user.photoURL ?? '',
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: const Color(0xFFE8849C),
    ));
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFFFF0F3);
    const pinkMain = Color(0xFFE8849C);
    const pinkDark = Color(0xFFD4708A);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 28),

              // ── Pixel Chat Bubble ────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 130,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                        top: 14,
                        left: 60,
                        child: Text('✦',
                            style: TextStyle(
                                color: pinkMain.withOpacity(0.55),
                                fontSize: 12))),
                    Positioned(
                        top: 10,
                        right: 55,
                        child: Text('✦',
                            style: TextStyle(
                                color: pinkDark.withOpacity(0.45),
                                fontSize: 10))),
                    Positioned(
                        bottom: 14,
                        left: 52,
                        child: Text('✦',
                            style: TextStyle(
                                color: pinkMain.withOpacity(0.4),
                                fontSize: 8))),
                    Positioned(
                        top: 20,
                        right: 80,
                        child: Icon(Icons.favorite,
                            color: pinkMain.withOpacity(0.65), size: 16)),
                    CustomPaint(
                      size: const Size(120, 100),
                      painter: PixelChatBubblePainter(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Pixel Dashed Border Card ──────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: CustomPaint(
                  painter: PixelDashBorderPainter(
                    color: pinkDark,
                    squareSize: 5,
                    gap: 4,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    child: Form(
                      key: _form,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLogin)
                            UserImagePicker(
                                onPickImage: (img) => _selectedImage = img),
                          if (!_isLogin) ...[
                            PinkPixelInputField(
                              label: 'Username',
                              autocorrect: false,
                              validator: (v) =>
                                  (v == null || v.trim().length < 4)
                                      ? 'Please enter at least 4 characters.'
                                      : null,
                              onSaved: (v) => _enteredUsername = v!,
                            ),
                            const SizedBox(height: 12),
                          ],
                          PinkPixelInputField(
                            label: 'Email Address',
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            validator: (v) => (v == null ||
                                    v.trim().isEmpty ||
                                    !v.contains('@'))
                                ? 'Please enter a valid email.'
                                : null,
                            onSaved: (v) => _enteredEmail = v!,
                          ),
                          const SizedBox(height: 12),
                          PinkPixelInputField(
                            label: 'Password',
                            obscure: true,
                            validator: (v) => (v == null || v.trim().length < 6)
                                ? 'Password must be at least 6 characters.'
                                : null,
                            onSaved: (v) => _enteredPassword = v!,
                          ),
                          const SizedBox(height: 20),
                          if (_isAuthenticating)
                            const CircularProgressIndicator(
                                color: Color(0xFFE8849C))
                          else ...[
                            // ── Login / Signup button ──────────────────
                            SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: pinkMain,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text(
                                  _isLogin ? 'Login' : 'Sign Up',
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            TextButton(
                              onPressed: () =>
                                  setState(() => _isLogin = !_isLogin),
                              style: TextButton.styleFrom(
                                  foregroundColor: pinkDark),
                              child: Text(
                                _isLogin
                                    ? 'Create an account'
                                    : 'I already have an account',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            const SizedBox(height: 4),

                            Row(children: [
                              Expanded(
                                  child: Divider(
                                      color: pinkMain.withOpacity(0.25),
                                      thickness: 1)),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text('or',
                                    style: TextStyle(
                                        color: pinkDark.withOpacity(0.6),
                                        fontSize: 12)),
                              ),
                              Expanded(
                                  child: Divider(
                                      color: pinkMain.withOpacity(0.25),
                                      thickness: 1)),
                            ]),
                            const SizedBox(height: 10),

                            // ── Google button ──────────────────────────
                            SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: OutlinedButton.icon(
                                onPressed: _signInWithGoogle,
                                icon: Image.network(
                                  'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                                  height: 20,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.login, size: 20),
                                ),
                                label: const Text('Login with Google',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF5A3040))),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: BorderSide(
                                      color: pinkMain.withOpacity(0.5),
                                      width: 1.5),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // ── Microsoft button ───────────────────────
                            SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: OutlinedButton.icon(
                                onPressed: _signInWithMicrosoft,
                                icon: Image.network(
                                  'https://upload.wikimedia.org/wikipedia/commons/4/44/Microsoft_logo.svg',
                                  height: 20,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.window, size: 20),
                                ),
                                label: const Text('Login with Microsoft',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF5A3040))),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: BorderSide(
                                      color: pinkMain.withOpacity(0.5),
                                      width: 1.5),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
