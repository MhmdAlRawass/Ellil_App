import 'dart:math';
import 'package:audio_app_example/app_localizations.dart';
import 'package:audio_app_example/providers/language_notifier.dart';
import 'package:audio_app_example/screens/auth/register.dart';
import 'package:audio_app_example/screens/tabs_screen.dart';
import 'package:audio_app_example/widgets/overlay_notification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/authentification.dart';

final email = TextEditingController();
final password = TextEditingController();

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final AuthenticationService _auth = AuthenticationService();
  bool _obscureText = true;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final contentWidth = sw < 600 ? sw : min(sw * 0.5, 450.0);

    double w(double fraction) => contentWidth * fraction;
    double h(double fraction) => sh * fraction;
    double f(double fraction) => sw * fraction;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: contentWidth,
              padding: EdgeInsets.symmetric(
                horizontal: w(0.06),
                vertical: h(0.04),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ===== Logo =====
                  Center(
                    child: Image.asset(
                      'assets/images/LOGO2.png',
                      width: w(0.35).clamp(90, 160),
                      height: w(0.35).clamp(90, 160),
                    ),
                  ),
                  SizedBox(height: h(0.04)),

                  // ===== Login Card =====
                  Container(
                    padding: EdgeInsets.all(w(0.05)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          AppLocalizations.tr('welcome_back_login', lang),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: f(0.06).clamp(20, 26),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppLocalizations.tr('sign_in_continue', lang),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: h(0.03)),

                        // Email field
                        TextField(
                          controller: email,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.tr('email', lang),
                            filled: true,
                            fillColor: Colors.grey[100],
                            labelStyle: TextStyle(color: Colors.grey[600]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        TextField(
                          controller: password,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.tr('password', lang),
                            filled: true,
                            fillColor: Colors.grey[100],
                            labelStyle: TextStyle(color: Colors.grey[600]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey[700],
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Login button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: EdgeInsets.symmetric(vertical: h(0.02)),
                            ),
                            onPressed: _loading
                                ? null
                                : () async {
                                    await _handleLogin(context);
                                    password.clear();
                                  },
                            child: _loading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    AppLocalizations.tr('login', lang),
                                    style: GoogleFonts.poppins(
                                      fontSize: f(0.045).clamp(14, 20),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: h(0.025)),

                        // ===== Divider =====
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(thickness: 1.2),
                            ),
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                AppLocalizations.tr('or', lang),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(thickness: 1.2),
                            ),
                          ],
                        ),
                        SizedBox(height: h(0.025)),

                        // Register button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 1.5,
                              ),
                              padding: EdgeInsets.symmetric(vertical: h(0.02)),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const RegisterPage()),
                              );
                            },
                            child: Text(
                              AppLocalizations.tr('create_account', lang),
                              style: GoogleFonts.poppins(
                                fontSize: f(0.045).clamp(14, 20),
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: h(0.03)),

                  // ===== About button =====
                  TextButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Text(
                          AppLocalizations.tr('about_login', lang),
                          style: GoogleFonts.poppins(),
                        ),
                        content: Text(
                          AppLocalizations.tr('about_message', lang),
                          style: GoogleFonts.poppins(fontSize: 15),
                        ),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.tr('about_this_app', lang),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin(context) async {
    setState(() => _loading = true);

    await _auth.signInWithEmailAndPassword(email.text, password.text);
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        OverlayAlert.show(
          context,
          message: 'Please enter valid credentials',
          type: AlertType.error,
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TabsScreen()),
        );
      }
    });

    setState(() => _loading = false);
  }
}
