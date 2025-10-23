import 'package:audio_app_example/widgets/purchased_audio_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/language_notifier.dart';
import '../app_localizations.dart';
import '../main.dart';
import '../upload.dart';
import 'auth/login.dart';
import '../services/authentification.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

String name = '';
String status = '';
String id = '';
bool flag = false;

class Account extends ConsumerStatefulWidget {
  const Account({Key? key}) : super(key: key);

  @override
  ConsumerState createState() => MyAccount();
}

class MyAccount extends ConsumerState<Account> {
  final AuthenticationService _auth = AuthenticationService();

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      id = user.uid;
    }

    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;

    CollectionReference users = FirebaseFirestore.instance.collection('Users');

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(id).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        List<String> purchasedAudioIds = [];

        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          name = data['Name'] ?? '';
          status = data['Status'] ?? '';
          flag = (status == 'CREATOR');
          if (data['purchasedAudioIds'] != null) {
            purchasedAudioIds = List<String>.from(data['purchasedAudioIds']);
          }
        }

        return Scaffold(
          backgroundColor: bcolor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header & Language Switch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.tr('account', lang),
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: tcolor,
                        ),
                      ),
                      Row(
                        children: [
                          Text(AppLocalizations.tr('latin', lang),
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: tcolor,
                              )),
                          Switch(
                            value: lang == AppLanguage.arabic,
                            onChanged: (val) {
                              // langNotifier.setLanguage(
                              //   val ? AppLanguage.arabic : AppLanguage.latin,
                              // );
                            },
                            activeColor: pcolor,
                          ),
                          Text(AppLocalizations.tr('arabic', lang),
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: tcolor,
                              )),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Profile Card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: pcolor.withOpacity(0.2),
                            child: Icon(Icons.person, size: 40, color: pcolor),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "${AppLocalizations.tr('hello', lang)} $name!",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: tcolor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${AppLocalizations.tr('you_are', lang)} $status",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: tcolor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Creator Upload Button
                  if (flag)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Up()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        backgroundColor: pcolor,
                      ),
                      icon: const Icon(Icons.arrow_circle_up,
                          color: Colors.white),
                      label: Text(
                        AppLocalizations.tr('import_podcast', lang),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Purchased Section
                  Text(
                    AppLocalizations.tr('my_purchased', lang),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: tcolor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  PurchasedAudiosList(
                    audioIds: purchasedAudioIds,
                    lang: lang,
                  ),

                  const SizedBox(height: 30),

                  // Actions List
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    elevation: 3,
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: Text(
                            AppLocalizations.tr('sign_out', lang),
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500),
                          ),
                          onTap: () async {
                            setState(() {
                              audioUrl = '';
                              image =
                                  'https://firebasestorage.googleapis.com/v0/b/audioapp-database.appspot.com/o/images%2Fdefault.jpg?alt=media&token=4080a33b-110a-4c03-bc5d-53768b61ba12';
                              audioTitle = '';
                              audioDescription = '';
                            });
                            await _auth.signOut();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (ctx) => const LoginPage()),
                            );
                          },
                        ),
                        const Divider(height: 0),
                        ListTile(
                          leading: const Icon(Icons.app_shortcut,
                              color: Colors.blueAccent),
                          title: Text(
                            theme == false
                                ? AppLocalizations.tr('theme_dark', lang)
                                : AppLocalizations.tr('theme_light', lang),
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500),
                          ),
                          onTap: () {
                            theme = !theme;
                            ServicesBinding.instance.reassembleApplication();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
