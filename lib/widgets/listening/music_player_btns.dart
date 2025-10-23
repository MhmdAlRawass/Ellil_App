import 'package:flutter/material.dart';

class MusicPlayerBtns extends StatefulWidget {
  const MusicPlayerBtns({
    super.key,
    required this.onPressedPlaybackSpeed,
    required this.playBackSpeed,
    required this.maxWidth,
    required this.onPressedComment,
  });

  final Function(double) onPressedPlaybackSpeed;
  final double playBackSpeed;
  final double maxWidth;
  final Function() onPressedComment;

  @override
  State<MusicPlayerBtns> createState() => _MusicPlayerBtnsState();
}

class _MusicPlayerBtnsState extends State<MusicPlayerBtns> {
  late double chosenSpeed;
  final List<double> playBackList = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  @override
  void initState() {
    super.initState();
    // Ensure a fallback if widget.playBackSpeed is null
    chosenSpeed = widget.playBackSpeed != 0 ? widget.playBackSpeed : 1.0;
  }

  void _cycleSpeed() {
    final currentIndex = playBackList.indexOf(chosenSpeed);
    final nextIndex = (currentIndex + 1) % playBackList.length;
    setState(() {
      chosenSpeed = playBackList[nextIndex];
    });
    widget.onPressedPlaybackSpeed(chosenSpeed);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;
    final maxWidth = widget.maxWidth;

    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // button to report/add audio to playlist
          // IconButton(
          //   iconSize: maxWidth * 0.085,
          //   onPressed: () {
          //     // if (audioUrl != '') {
          //     //   showDialog(
          //     //     context: context,
          //     //     builder: (BuildContext context) {
          //     //       return AlertDialog(
          //     //         content: Column(
          //     //           mainAxisSize: MainAxisSize.min,
          //     //           children: <Widget>[
          //     //             ElevatedButton(
          //     //               style: ElevatedButton.styleFrom(
          //     //                 shape: const StadiumBorder(),
          //     //                 backgroundColor: Colors.grey,
          //     //                 padding: EdgeInsets.all(0.05 * maxWidth),
          //     //               ),
          //     //               onPressed: () {
          //     //                 showDialog(
          //     //                   context: context,
          //     //                   builder: (BuildContext context) {
          //     //                     return FutureBuilder<QuerySnapshot>(
          //     //                       future: FirebaseFirestore.instance
          //     //                           .collection('Users')
          //     //                           .doc(FirebaseAuth
          //     //                               .instance.currentUser?.uid)
          //     //                           .collection('Playlists')
          //     //                           .get(),
          //     //                       builder: (BuildContext context,
          //     //                           AsyncSnapshot<QuerySnapshot>
          //     //                               snapshot) {
          //     //                         if (snapshot.hasError) {
          //     //                           return Text(
          //     //                               'Erreur : ${snapshot.error}');
          //     //                         }
          //     //                         if (!snapshot.hasData) {
          //     //                           return const CircularProgressIndicator();
          //     //                         }
          //     //                         return Dialog(
          //     //                           child: SingleChildScrollView(
          //     //                             child: ListBody(
          //     //                               children: snapshot.data!.docs
          //     //                                   .where((doc) =>
          //     //                                       doc.id != 'Favorites')
          //     //                                   .map((doc) {
          //     //                                 return GestureDetector(
          //     //                                   onTap: () {
          //     //                                     String choix = doc.id;
          //     //                                     FirebaseFirestore
          //     //                                         .instance
          //     //                                         .collection('Users')
          //     //                                         .doc(FirebaseAuth
          //     //                                             .instance
          //     //                                             .currentUser
          //     //                                             ?.uid)
          //     //                                         .collection(
          //     //                                             'Playlists')
          //     //                                         .doc(choix)
          //     //                                         .update({
          //     //                                       'audios': FieldValue
          //     //                                           .arrayUnion(
          //     //                                               [audioTitle])
          //     //                                     });
          //     //                                     ScaffoldMessenger.of(
          //     //                                             context)
          //     //                                         .showSnackBar(
          //     //                                       const SnackBar(
          //     //                                         content: Text(
          //     //                                             'Correctely added to the playlist !'),
          //     //                                         duration: Duration(
          //     //                                             seconds: 1),
          //     //                                       ),
          //     //                                     );
          //     //                                     Navigator.of(context)
          //     //                                         .pop();
          //     //                                     Navigator.of(context)
          //     //                                         .pop();
          //     //                                   },
          //     //                                   child: ListTile(
          //     //                                     title: Text(doc.id),
          //     //                                   ),
          //     //                                 );
          //     //                               }).toList(),
          //     //                             ),
          //     //                           ),
          //     //                         );
          //     //                       },
          //     //                     );
          //     //                   },
          //     //                 );
          //     //               },
          //     //               child: const Text('Add to playlist'),
          //     //             ),
          //     //             const SizedBox(height: 16.0),
          //     //             ElevatedButton(
          //     //               style: ElevatedButton.styleFrom(
          //     //                 shape: const StadiumBorder(),
          //     //                 backgroundColor: Colors.grey,
          //     //                 padding: EdgeInsets.all(0.05 * maxWidth),
          //     //               ),
          //     //               onPressed: () {
          //     //                 FirebaseFirestore.instance
          //     //                     .collection('Audios')
          //     //                     .doc(audioTitle)
          //     //                     .update({
          //     //                   'Reports': FieldValue.increment(1)
          //     //                 });
          //     //                 Navigator.of(context).pop();
          //     //                 ScaffoldMessenger.of(context).showSnackBar(
          //     //                   const SnackBar(
          //     //                     content: Text('Correctely reported !'),
          //     //                     duration: Duration(seconds: 1),
          //     //                   ),
          //     //                 );
          //     //               },
          //     //               child: const Text('Report'),
          //     //             ),
          //     //           ],
          //     //         ),
          //     //       );
          //     //     },
          //     //   );
          //     // }
          //   },
          //   icon: Icon(
          //     Icons.more_horiz_rounded,
          //     color: theme.colorScheme.primary,
          //   ),
          // ),
          // // button to add/consult notes
          IconButton(
            iconSize: maxWidth * 0.085,
            onPressed: () async {
              widget.onPressedComment();
            },
            icon: Icon(
              Icons.comment_outlined,
              color: theme.colorScheme.primary,
            ),
          ),
          // sharing button
          IconButton(
            iconSize: maxWidth * 0.085,
            onPressed: () async {
              // if (audioUrl.isNotEmpty) {
              //   await Share.share(
              //     audioUrl,
              //     subject: 'Example share',
              //   );
              // }
            },
            icon: Icon(
              Icons.share,
              color: theme.colorScheme.primary,
            ),
          ),

          TextButton(
            onPressed: _cycleSpeed,
            child: Text('${chosenSpeed}x'),
          ),
          // option to change the playing speed
          // DropdownButton<double>(
          //   iconSize: maxWidth * 0.085,
          //   value: widget.playBackSpeed,
          //   dropdownColor: Colors.grey[900],
          //   style: TextStyle(
          //     color: theme.colorScheme.primary,
          //     fontSize: 15,
          //   ),
          //   icon: Icon(
          //     Icons.speed,
          //     color: theme.colorScheme.primary,
          //   ),
          //   items: const [
          //     DropdownMenuItem(
          //       value: 0.5,
          //       child: Text('0.5'),
          //     ),
          //     DropdownMenuItem(
          //       value: 1.0,
          //       child: Text('1.0'),
          //     ),
          //     DropdownMenuItem(
          //       value: 1.5,
          //       child: Text('1.5'),
          //     ),
          //     DropdownMenuItem(
          //       value: 2.0,
          //       child: Text('2.0'),
          //     ),
          //   ],
          //   onChanged: (value) {
          //     //   setState(() {
          //     //     _playbackSpeed = value!;
          //     //   });
          //     //   widget.audioPlayer.setSpeed(value!);
          //   },
          // ),
        ],
      ),
    );
  }
}
