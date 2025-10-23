import 'package:audio_app_example/app_localizations.dart';
import 'package:audio_app_example/providers/language_notifier.dart';
import 'package:audio_app_example/screens/tabs_screen.dart';
import 'package:audio_app_example/widgets/overlay_notification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/authentification.dart';

final email = TextEditingController();
final password = TextEditingController();
final confirm = TextEditingController();
final nom = TextEditingController();
DateTime? _selectedDate;
final dobController = TextEditingController();

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final AuthenticationService _auth = AuthenticationService();
  bool isRegistering = false;

  void _showErrorDialog(BuildContext context, String message) {
    OverlayAlert.show(context, message: message, type: AlertType.error);
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 28.sp),
          onPressed: () {
            email.clear();
            password.clear();
            nom.clear();
            confirm.clear();
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.tr('create_account', lang),
                style: GoogleFonts.poppins(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                AppLocalizations.tr('register_description', lang),
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),

              // === Card Container ===
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      spreadRadius: 2,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: const RegisterForm(),
              ),
              SizedBox(height: 24.h),

              ElevatedButton(
                onPressed: () async {
                  if (email.text.isEmpty ||
                      password.text.isEmpty ||
                      nom.text.isEmpty ||
                      dobController.text.isEmpty) {
                    _showErrorDialog(
                        context, AppLocalizations.tr('fill_info', lang));
                  } else if (password.text != confirm.text) {
                    _showErrorDialog(context,
                        AppLocalizations.tr('passwords_not_match', lang));
                  } else {
                    setState(() {
                      isRegistering = true;
                    });
                    await _auth.registerWithEmailAndPassword(
                      nom.text,
                      email.text,
                      password.text,
                      _selectedDate,
                    );

                    FirebaseAuth.instance
                        .authStateChanges()
                        .listen((User? user) {
                      if (user == null) {
                        setState(() {
                          isRegistering = false;
                        });
                        _showErrorDialog(
                            context, AppLocalizations.tr('review_info', lang));
                      } else {
                        dobController.clear();
                        nom.clear();
                        password.clear();
                        email.clear();
                        confirm.clear();
                        _selectedDate = null;
                        setState(() {
                          isRegistering = false;
                        });
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const TabsScreen()),
                        );
                      }
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding:
                      EdgeInsets.symmetric(vertical: 16.h, horizontal: 40.w),
                  elevation: 3,
                ),
                child: isRegistering
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        AppLocalizations.tr('register', lang),
                        style: GoogleFonts.poppins(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterForm extends ConsumerStatefulWidget {
  const RegisterForm({super.key});

  @override
  ConsumerState<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<RegisterForm> {
  var _obscureText = true;
  var _obscureText2 = true;

  InputDecoration _inputDecoration(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[600], fontSize: 15.sp),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      suffixIcon: suffixIcon,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDate: DateTime(2000, 1),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        dobController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);

    return Column(
      children: [
        TextField(
          controller: nom,
          decoration: _inputDecoration(
            AppLocalizations.tr('your_name', lang),
          ),
        ),
        SizedBox(height: 20.h),
        TextField(
          controller: email,
          decoration: _inputDecoration(AppLocalizations.tr('your_email', lang)),
        ),
        SizedBox(height: 20.h),
        TextField(
          controller: dobController,
          readOnly: true,
          decoration: _inputDecoration(
            AppLocalizations.tr('date_of_birth', lang),
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_month_outlined),
              onPressed: () => _selectDate(context),
            ),
          ),
          onTap: () => _selectDate(context),
        ),
        SizedBox(height: 20.h),
        TextField(
          controller: password,
          obscureText: _obscureText,
          decoration: _inputDecoration(
            AppLocalizations.tr('password', lang),
            suffixIcon: IconButton(
              icon:
                  Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _obscureText = !_obscureText),
            ),
          ),
        ),
        SizedBox(height: 20.h),
        TextField(
          controller: confirm,
          obscureText: _obscureText2,
          decoration: _inputDecoration(
            AppLocalizations.tr('confirm_password', lang),
            suffixIcon: IconButton(
              icon:
                  Icon(_obscureText2 ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _obscureText2 = !_obscureText2),
            ),
          ),
        ),
      ],
    );
  }
}
