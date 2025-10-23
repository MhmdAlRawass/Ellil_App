import 'package:audio_app_example/Pages/playlist.dart';
import 'package:audio_app_example/screens/account.dart';
import 'package:audio_app_example/screens/tabs/home.dart';
import 'package:audio_app_example/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/language_notifier.dart';
import '../app_localizations.dart';

final controller = TextEditingController();

class Favorites extends ConsumerStatefulWidget {
  const Favorites({Key? key}) : super(key: key);

  @override
  ConsumerState createState() => Fav();
}

class Fav extends ConsumerState<Favorites> {
  int _selectedIndex = 1;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (_selectedIndex) {
      case 0:
        Navigator.pop(context);
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const Home(),
          ),
        );
        break;
      case 2:
        Navigator.pop(context);
        ServicesBinding.instance.reassembleApplication();
        break;
      case 3:
        Navigator.pop(context);
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const Account(),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final contentMaxWidth = width < 600 ? width : 460.0;

    return GestureDetector(
      onPanUpdate: (details) {
        if (details.delta.dx > 0) {
          _onItemTapped(0);
        }
        if (details.delta.dx < 0) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: bcolor,
        body: Center(
          child: Container(
            width: contentMaxWidth,
            padding: EdgeInsets.symmetric(
                horizontal: width < 600 ? 12 : 20,
                vertical: width < 600 ? 16 : 28),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: width * 0.1),
                  // Title Row
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.tr('playlist', lang),
                          style: TextStyle(
                              color: tcolor,
                              fontSize: width < 600 ? 22 : 30,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: width < 600 ? 44 : 56,
                          width: width < 600 ? 44 : 56,
                          child: Icon(
                            Icons.playlist_play,
                            color: tcolor,
                            size: width < 600 ? 28 : 38,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Favorites card
                  GestureDetector(
                    onTap: () {
                      playlist = 'Favorites';
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const Playlist(),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: double.infinity,
                      height: height * 0.11,
                      child: Card(
                        color: Colors.grey[300],
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.tr('favourites', lang),
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: width < 600 ? 18 : 22,
                                ),
                              ),
                              const Icon(
                                Icons.favorite,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.020),
                  Container(
                    color: pcolor,
                    height: 2,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 12),
                  Liste(lang: lang, maxWidth: contentMaxWidth),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: pcolor,
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(AppLocalizations.tr('new_playlist', lang)),
                  content: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.tr('name', lang),
                    ),
                  ),
                  actions: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        backgroundColor: Colors.grey,
                        padding: EdgeInsets.all(width * 0.04),
                      ),
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection('Users')
                            .doc(FirebaseAuth.instance.currentUser?.uid)
                            .collection('Playlists')
                            .doc(controller.text)
                            .set({'audios': []});
                        controller.clear();
                        Navigator.of(context).pop();
                      },
                      child: Text(AppLocalizations.tr('create', lang)),
                    ),
                  ],
                );
              },
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class Liste extends StatelessWidget {
  final AppLanguage lang;
  final double maxWidth;
  const Liste({Key? key, required this.lang, required this.maxWidth})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    // Playlists from user
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('Playlists')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text(
              '${AppLocalizations.tr('error', lang)}: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(AppLocalizations.tr('loading', lang));
        }
        final playlists = snapshot.data?.docs ?? [];

        if (playlists.length <= 1) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(AppLocalizations.tr('no_playlists', lang),
                style: const TextStyle(color: Colors.grey)),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: playlists.length,
          itemBuilder: (BuildContext context, int index) {
            if (playlists[index].id == "Favorites") {
              return const SizedBox.shrink();
            }
            return GestureDetector(
              onTap: () {
                playlist = playlists[index].id;
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const Playlist(),
                  ),
                );
              },
              child: SizedBox(
                width: double.infinity,
                height: height * 0.09,
                child: Card(
                  color: Colors.grey[200],
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          playlists[index].id,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: width < 600 ? 16 : 19,
                          ),
                        ),
                        const Icon(
                          Icons.turn_right,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
