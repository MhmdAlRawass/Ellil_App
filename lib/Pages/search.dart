//pages that open when the user search audios from the home page
import 'package:audio_app_example/screens/tabs/listening.dart';
import 'package:audio_app_example/main.dart';
import 'package:audio_app_example/models/audio.dart';
import 'package:audio_app_example/models/user.dart';
import 'package:audio_app_example/screens/tabs_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../Services-old/database.dart';

//works like the iconlist page
class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  SearchState createState() => SearchState();
}

class SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;
    return StreamProvider<List<AppAudioData>>.value(
      value: DatabaseService("").searchAudios,
      initialData: const [],
      child: Scaffold(
        backgroundColor: bcolor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: bcolor,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: tcolor,
              size: 30,
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const TabsScreen(),
                ),
              );
            },
          ),
          title: Text(
            'Search',
            style: TextStyle(
              color: tcolor,
              fontSize: width * 0.075,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: height * 0.01,
              ),
              Row(
                children: [
                  SizedBox(width: width * 0.05),
                  Text(
                    'Corresponding to : "$research"',
                    textAlign: TextAlign.left,
                    style: TextStyle(color: tcolor, fontSize: width * 0.04),
                  ),
                ],
              ),
              SizedBox(
                height: height * 0.025,
              ),
              const Audios(),
              SizedBox(
                height: height * 0.07,
              ),
              Icon(
                Icons.sentiment_very_dissatisfied,
                color: Colors.grey,
                size: width * 0.1,
              ),
              SizedBox(
                height: height * 0.015,
              ),
              Text(
                'Sorry... no more corresponding podcast',
                style: TextStyle(color: Colors.grey, fontSize: width * 0.035),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Audios extends StatefulWidget {
  const Audios({Key? key}) : super(key: key);
  @override
  AuiosState createState() => AuiosState();
}

class AuiosState extends State<Audios> {
  @override
  Widget build(BuildContext context) {
    final audios = Provider.of<List<AppAudioData>>(context);
    return ListView.builder(
        shrinkWrap: true,
        itemCount: audios.length,
        itemBuilder: (context, index) {
          return UserTile(audios[index]);
        });
  }
}

class UserTile extends StatefulWidget {
  final AppAudioData audi;

  const UserTile(this.audi, {super.key});

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;
    final currentAudio = Provider.of<AppUser?>(context);
    final FirebaseStorage stor = FirebaseStorage.instance;
    String titre = "${widget.audi.name} - ${widget.audi.author}";
    final ref = stor.ref().child('images/${widget.audi.uid}');
    //filter to get only the audios corresponding to the research
    if (widget.audi.name == '|||') {
      return Container();
    }
    return GestureDetector(
      onTap: () async {
        final u = await stor
            .ref()
            .child('audios/${widget.audi.uid}')
            .getDownloadURL();
        final i = await ref.getDownloadURL();
        setState(() {
          audioUrl = u;
          image = i;
          audioTitle = widget.audi.uid;
          audioDescription = widget.audi.description;
        });
        DocumentSnapshot<Map<String, dynamic>> snap = await FirebaseFirestore
            .instance
            .collection('Audios')
            .doc(audioTitle)
            .get();
        final t = await test();
        setState(() {
          likeNbr = snap.data()!['Likes'];
          tester = t;
        });
        Navigator.of(context).pop();
        ServicesBinding.instance.reassembleApplication();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Listening()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 0.0),
        child: Card(
          color: Colors.grey[200],
          elevation: 0,
          margin: EdgeInsets.only(
              top: width * 0.002,
              bottom: width * 0.0130,
              left: width * 0.05,
              right: width * 0.05),
          child: FutureBuilder<String>(
            future: ref.getDownloadURL(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                return ListTile(
                  leading: Container(
                    width: width * 0.175,
                    height: width * 0.15,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(snapshot.data!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  trailing: const Icon(
                    Icons.play_circle_fill,
                    color: Colors.grey,
                  ),
                  title: Text(titre),
                  subtitle: Text(
                    widget.audi.description,
                    maxLines: 2,
                  ),
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }
}

Future<bool> test() async {
  bool exists = false;
  await FirebaseFirestore.instance
      .collection('Users')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .collection('Playlists')
      .doc('Favorites')
      .get()
      .then((docSnapshot) {
    if (docSnapshot.exists) {
      List<dynamic> tableau =
          List<String>.from(docSnapshot.data()?['audios'] ?? []);
      if (tableau.contains(audioTitle)) {
        exists = true;
      }
    } else {
      return exists;
    }
  });
  return exists;
}
