import 'package:audio_app_example/screens/tabs/listening.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/authentification.dart';

// Defining controllers for the form
final email = TextEditingController();
final password = TextEditingController();
bool corr = false;

class EmailLogin extends StatelessWidget {
  final AuthenticationService _auth = AuthenticationService();

  EmailLogin({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    // Responsive: Limit form width & center for web
    final double maxFormWidth = width < 500 ? width : 400.0;
    final EdgeInsets contentPadding = width < 500
        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 20)
        : EdgeInsets.symmetric(
            horizontal: (width - maxFormWidth) / 2, vertical: 40);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: width < 500 ? 28 : 32,
          ),
          onPressed: () {
            email.text = '';
            password.text = '';
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: contentPadding,
          child: Center(
            child: Container(
              width: maxFormWidth,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: width > 500
                    ? [
                        const BoxShadow(
                            color: Colors.black12,
                            blurRadius: 16,
                            spreadRadius: 2)
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Connect email address",
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: width < 500 ? 20 : 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const LoginForm(),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _auth.signInWithEmailAndPassword(
                            email.text, password.text);
                        FirebaseAuth.instance
                            .authStateChanges()
                            .listen((User? user) {
                          if (user == null) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return const AlertDialog(
                                  content: Text(
                                      'Please, review the info you entered'),
                                );
                              },
                            );
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Listening(),
                              ),
                            );
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'CONFIRM',
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: width < 500 ? 15 : 17,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey[100],
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  var _obscureText = true;
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        TextField(
          controller: email,
          decoration: InputDecoration(
            labelText: 'Your Email',
            labelStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: width < 500 ? 15 : 17,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[400]),
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: password,
          obscureText: _obscureText,
          decoration: InputDecoration(
            labelStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: width < 500 ? 15 : 17,
            ),
            labelText: 'Password',
            prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
                color: Colors.black,
                size: width < 500 ? 20 : 22,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
