//page that open when the user click on the playlists from the playlists page
import 'package:audio_app_example/screens/tabs/listening.dart';
import 'package:audio_app_example/main.dart';
import 'package:audio_app_example/models/audio.dart';
import 'package:audio_app_example/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../Services-old/database.dart';

//works the same way as the iconlist file
class Playlist extends StatefulWidget {
  const Playlist({Key? key}) : super(key: key);

  @override
  PlaylistState createState() => PlaylistState();
}

class PlaylistState extends State<Playlist> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;
    return StreamProvider<List<AppAudioData>>.value(
      value: DatabaseService("").audios,
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
            },
          ),
          title: (playlist == 'Favorites')
              ? Text(
                  'Favourites',
                  style: TextStyle(
                    color: tcolor,
                    fontSize: width * 0.075,
                  ),
                )
              : Text(
                  playlist,
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
              const Audios(),
            ],
          ),
        ),
        //provides a button to delete the playlist if it is not the 'Favorites' one
        floatingActionButton: playlist != 'Favorites'
            ? FloatingActionButton(
                backgroundColor: pcolor,
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection('Users')
                      .doc(FirebaseAuth.instance.currentUser?.uid)
                      .collection('Playlists')
                      .doc(playlist)
                      .delete();
                  Navigator.pop(context);
                },
                child: const Icon(Icons.delete),
              )
            : null,
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
    DocumentReference playlistRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('Playlists')
        .doc(playlist);
    return FutureBuilder<DocumentSnapshot>(
        future: playlistRef.get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasData) {
            //gets the list from the playlist
            if (snapshot.data!.exists) {
              Map<String, dynamic> playlistData = Map<String, dynamic>.from(
                      snapshot.data!.data() as Map<String, dynamic>)
                  .cast<String, dynamic>();
              List<String> myArray = List<String>.from(playlistData['audios']);
              for (String element in myArray) {
                //goes through all the register audios and check if they are in the playlist
                if (widget.audi.uid == element) {
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
                      DocumentSnapshot<Map<String, dynamic>> snap =
                          await FirebaseFirestore.instance
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
                          builder: (BuildContext context,
                              AsyncSnapshot<String> snapshot) {
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
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.grey),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('Users')
                                        .doc(FirebaseAuth
                                            .instance.currentUser?.uid)
                                        .collection('Playlists')
                                        .doc(playlist)
                                        .update({
                                      'audios': FieldValue.arrayRemove(
                                          [widget.audi.uid])
                                    });
                                    if (widget.audi.uid == audioTitle) {
                                      tester = false;
                                    }
                                    ServicesBinding.instance
                                        .reassembleApplication();
                                  },
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
            }
          }
          return Container();
        });
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
