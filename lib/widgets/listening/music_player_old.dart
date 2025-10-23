// import 'package:audio_app_example/Pages/note.dart';
// import 'package:audio_app_example/main.dart';
// import 'package:audio_app_example/screens/tabs/listening.dart';
// import 'package:audio_app_example/widgets/widgets.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:share_plus/share_plus.dart';

// class MusicPlayerOld extends StatefulWidget {
//   const MusicPlayerOld({
//     Key? key,
//     required Stream<SeekBarData> seekBarDataStream,
//     required this.audioPlayer,
//     required this.isPurchased,
//     required this.price,
//     required this.onPay,
//     this.maxWidth = 500,
//   })  : _seekBarDataStream = seekBarDataStream,
//         super(key: key);

//   final Stream<SeekBarData> _seekBarDataStream;
//   final AudioPlayer audioPlayer;
//   final bool isPurchased;
//   final double price;
//   final VoidCallback onPay;
//   final double maxWidth;

//   @override
//   State<MusicPlayerOld> createState() => _MusicPlayerOldState();
// }

// class _MusicPlayerOldState extends State<MusicPlayerOld> {
//   double _playbackSpeed = 1.0;

//   void _setPlaybackSpeed(double speed) {
//     setState(() {
//       _playbackSpeed = speed;
//     });
//     widget.audioPlayer.setSpeed(speed);
//   }

//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     var height = size.height;
//     var width = size.width;
//     final maxWidth = widget.maxWidth;

//     return Padding(
//       padding: EdgeInsets.symmetric(
//           horizontal: maxWidth * 0.07, vertical: height * 0.04),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           const Text(
//             'Book Name',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 18,
//             ),
//           ),
//           const SizedBox(
//             height: 6,
//           ),
//           const Text(
//             'Writer',
//             style: TextStyle(
//               fontSize: 14,
//             ),
//           ),
//           SizedBox(height: height * 0.03),
//           StreamBuilder<SeekBarData>(
//             stream: widget._seekBarDataStream,
//             builder: (context, snapshot) {
//               final positionData = snapshot.data;
//               // return SeekBar(
//               //   position: positionData?.position ?? Duration.zero,
//               //   duration: positionData?.duration ?? const Duration(minutes: 10),
//               //   onChangeEnd: widget.audioPlayer.seek,

//               // );
//               return SeekBar(
//                 position: Duration.zero,
//                 duration: const Duration(minutes: 10),
//                 onChangeEnd: widget.audioPlayer.seek,
//               );
//             },
//           ),
//           SizedBox(height: height * 0.02),
//           Playerbuttons(
//             audioPlayer: widget.audioPlayer,
//             isPurchased: widget.isPurchased,
//             price: widget.price,
//             onPay: widget.onPay,
//             ,
//           ),
//           SizedBox(height: height * 0.02),
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // button to report/add audio to playlist
//                 IconButton(
//                   iconSize: maxWidth * 0.085,
//                   onPressed: () {
//                     if (audioUrl != '') {
//                       showDialog(
//                         context: context,
//                         builder: (BuildContext context) {
//                           return AlertDialog(
//                             content: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: <Widget>[
//                                 ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                     shape: const StadiumBorder(),
//                                     backgroundColor: Colors.grey,
//                                     padding: EdgeInsets.all(0.05 * maxWidth),
//                                   ),
//                                   onPressed: () {
//                                     showDialog(
//                                       context: context,
//                                       builder: (BuildContext context) {
//                                         return FutureBuilder<QuerySnapshot>(
//                                           future: FirebaseFirestore.instance
//                                               .collection('Users')
//                                               .doc(FirebaseAuth
//                                                   .instance.currentUser?.uid)
//                                               .collection('Playlists')
//                                               .get(),
//                                           builder: (BuildContext context,
//                                               AsyncSnapshot<QuerySnapshot>
//                                                   snapshot) {
//                                             if (snapshot.hasError) {
//                                               return Text(
//                                                   'Erreur : ${snapshot.error}');
//                                             }
//                                             if (!snapshot.hasData) {
//                                               return const CircularProgressIndicator();
//                                             }
//                                             return Dialog(
//                                               child: SingleChildScrollView(
//                                                 child: ListBody(
//                                                   children: snapshot.data!.docs
//                                                       .where((doc) =>
//                                                           doc.id != 'Favorites')
//                                                       .map((doc) {
//                                                     return GestureDetector(
//                                                       onTap: () {
//                                                         String choix = doc.id;
//                                                         FirebaseFirestore
//                                                             .instance
//                                                             .collection('Users')
//                                                             .doc(FirebaseAuth
//                                                                 .instance
//                                                                 .currentUser
//                                                                 ?.uid)
//                                                             .collection(
//                                                                 'Playlists')
//                                                             .doc(choix)
//                                                             .update({
//                                                           'audios': FieldValue
//                                                               .arrayUnion(
//                                                                   [audioTitle])
//                                                         });
//                                                         ScaffoldMessenger.of(
//                                                                 context)
//                                                             .showSnackBar(
//                                                           const SnackBar(
//                                                             content: Text(
//                                                                 'Correctely added to the playlist !'),
//                                                             duration: Duration(
//                                                                 seconds: 1),
//                                                           ),
//                                                         );
//                                                         Navigator.of(context)
//                                                             .pop();
//                                                         Navigator.of(context)
//                                                             .pop();
//                                                       },
//                                                       child: ListTile(
//                                                         title: Text(doc.id),
//                                                       ),
//                                                     );
//                                                   }).toList(),
//                                                 ),
//                                               ),
//                                             );
//                                           },
//                                         );
//                                       },
//                                     );
//                                   },
//                                   child: const Text('Add to playlist'),
//                                 ),
//                                 const SizedBox(height: 16.0),
//                                 ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                     shape: const StadiumBorder(),
//                                     backgroundColor: Colors.grey,
//                                     padding: EdgeInsets.all(0.05 * maxWidth),
//                                   ),
//                                   onPressed: () {
//                                     FirebaseFirestore.instance
//                                         .collection('Audios')
//                                         .doc(audioTitle)
//                                         .update({
//                                       'Reports': FieldValue.increment(1)
//                                     });
//                                     Navigator.of(context).pop();
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(
//                                         content: Text('Correctely reported !'),
//                                         duration: Duration(seconds: 1),
//                                       ),
//                                     );
//                                   },
//                                   child: const Text('Report'),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       );
//                     }
//                   },
//                   icon: const Icon(
//                     Icons.more_horiz_rounded,
//                     color: Colors.white,
//                   ),
//                 ),
//                 // button to add/consult notes
//                 IconButton(
//                   iconSize: maxWidth * 0.085,
//                   onPressed: () async {
//                     if (audioUrl != '') {
//                       display = '';
//                       bool ex = false;
//                       await FirebaseFirestore.instance
//                           .collection('Users')
//                           .doc(FirebaseAuth.instance.currentUser?.uid)
//                           .collection('Notes')
//                           .doc(audioTitle)
//                           .get()
//                           .then((docSnapshot) {
//                         if (docSnapshot.exists) {
//                           ex = true;
//                         }
//                       });
//                       showDialog(
//                         context: context,
//                         builder: (BuildContext context) {
//                           return AlertDialog(
//                             content: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: <Widget>[
//                                 ElevatedButton(
//                                   style: ElevatedButton.styleFrom(
//                                     shape: const StadiumBorder(),
//                                     backgroundColor: Colors.grey,
//                                     padding: EdgeInsets.all(0.05 * maxWidth),
//                                   ),
//                                   onPressed: () {
//                                     Navigator.of(context).pop();
//                                     showDialog(
//                                       context: context,
//                                       builder: (BuildContext context) =>
//                                           NoteDialog(
//                                         audioPlayer: widget.audioPlayer,
//                                         ex: ex,
//                                       ),
//                                     );
//                                   },
//                                   child: const Text('Add notes'),
//                                 ),
//                                 const SizedBox(height: 16.0),
//                                 (ex == true)
//                                     ? ElevatedButton(
//                                         style: ElevatedButton.styleFrom(
//                                           shape: const StadiumBorder(),
//                                           backgroundColor: Colors.grey,
//                                           padding:
//                                               EdgeInsets.all(0.05 * maxWidth),
//                                         ),
//                                         onPressed: () async {
//                                           DocumentSnapshot notesSnapshot =
//                                               await FirebaseFirestore.instance
//                                                   .collection('Users')
//                                                   .doc(FirebaseAuth.instance
//                                                       .currentUser?.uid)
//                                                   .collection('Notes')
//                                                   .doc(audioTitle)
//                                                   .get();
//                                           Map<String, dynamic> prise =
//                                               Map<String, dynamic>.from(
//                                                   notesSnapshot.data()
//                                                       as Map<String, dynamic>);
//                                           List<String> myArray =
//                                               List<String>.from(prise['notes']);
//                                           for (var item in myArray) {
//                                             display =
//                                                 '$display $item' '\r\n\r\n';
//                                           }
//                                           Navigator.of(context).pop();
//                                           showDialog(
//                                             context: context,
//                                             builder: (BuildContext context) {
//                                               return AlertDialog(
//                                                 title: const Text('Notes'),
//                                                 content: SingleChildScrollView(
//                                                   child: Column(
//                                                     children: [
//                                                       Text(display),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               );
//                                             },
//                                           );
//                                         },
//                                         child: const Text('Consult notes'),
//                                       )
//                                     : ElevatedButton(
//                                         style: ElevatedButton.styleFrom(
//                                           shape: const StadiumBorder(),
//                                           backgroundColor: Colors.grey,
//                                           padding:
//                                               EdgeInsets.all(0.05 * maxWidth),
//                                         ),
//                                         onPressed: () {},
//                                         child: const Text('No current notes'),
//                                       ),
//                               ],
//                             ),
//                           );
//                         },
//                       );
//                     }
//                   },
//                   icon: const Icon(
//                     Icons.comment_outlined,
//                     color: Colors.white,
//                   ),
//                 ),
//                 // sharing button
//                 IconButton(
//                   iconSize: maxWidth * 0.085,
//                   onPressed: () async {
//                     if (audioUrl.isNotEmpty) {
//                       await Share.share(
//                         audioUrl,
//                         subject: 'Example share',
//                       );
//                     }
//                   },
//                   icon: const Icon(
//                     Icons.share,
//                     color: Colors.white,
//                   ),
//                 ),
//                 // option to change the playing speed
//                 DropdownButton<double>(
//                   iconSize: maxWidth * 0.085,
//                   value: _playbackSpeed,
//                   dropdownColor: Colors.grey[900],
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 15,
//                   ),
//                   icon: const Icon(
//                     Icons.speed,
//                     color: Colors.white,
//                   ),
//                   items: const [
//                     DropdownMenuItem(
//                       value: 0.5,
//                       child: Text('0.5'),
//                     ),
//                     DropdownMenuItem(
//                       value: 1.0,
//                       child: Text('1.0'),
//                     ),
//                     DropdownMenuItem(
//                       value: 1.5,
//                       child: Text('1.5'),
//                     ),
//                     DropdownMenuItem(
//                       value: 2.0,
//                       child: Text('2.0'),
//                     ),
//                   ],
//                   onChanged: (value) {
//                     setState(() {
//                       _playbackSpeed = value!;
//                     });
//                     widget.audioPlayer.setSpeed(value!);
//                   },
//                 ),
//                 // adding or removing audio from favorites
//                 (tester)
//                     ? IconButton(
//                         iconSize: maxWidth * 0.085,
//                         onPressed: () {
//                           FirebaseFirestore.instance
//                               .collection('Audios')
//                               .doc(audioTitle)
//                               .update({'Likes': FieldValue.increment(-1)});
//                           FirebaseFirestore.instance
//                               .collection('Users')
//                               .doc(FirebaseAuth.instance.currentUser?.uid)
//                               .collection('Playlists')
//                               .doc('Favorites')
//                               .update({
//                             'audios': FieldValue.arrayRemove([audioTitle])
//                           });
//                           setState(() {
//                             tester = false;
//                             likeNbr = likeNbr - 1;
//                           });
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content:
//                                   Text('Correctely removed from Favorites !'),
//                               duration: Duration(seconds: 1),
//                             ),
//                           );
//                         },
//                         icon: const Icon(
//                           Icons.favorite,
//                           color: Colors.white,
//                         ),
//                       )
//                     : IconButton(
//                         iconSize: maxWidth * 0.085,
//                         onPressed: () async {
//                           if (audioUrl != '') {
//                             FirebaseFirestore.instance
//                                 .collection('Audios')
//                                 .doc(audioTitle)
//                                 .update({'Likes': FieldValue.increment(1)});
//                             await FirebaseFirestore.instance
//                                 .collection('Users')
//                                 .doc(FirebaseAuth.instance.currentUser?.uid)
//                                 .collection('Playlists')
//                                 .doc('Favorites')
//                                 .get()
//                                 .then((docSnapshot) {
//                               if (!docSnapshot.exists) {
//                                 FirebaseFirestore.instance
//                                     .collection('Users')
//                                     .doc(FirebaseAuth.instance.currentUser?.uid)
//                                     .collection('Playlists')
//                                     .doc('Favorites')
//                                     .set({
//                                   'audios': FieldValue.arrayUnion([audioTitle])
//                                 });
//                                 setState(() {
//                                   tester = true;
//                                   likeNbr = likeNbr + 1;
//                                 });
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content:
//                                         Text('Correctely added to Favorites !'),
//                                     duration: Duration(seconds: 1),
//                                   ),
//                                 );
//                               } else {
//                                 FirebaseFirestore.instance
//                                     .collection('Users')
//                                     .doc(FirebaseAuth.instance.currentUser?.uid)
//                                     .collection('Playlists')
//                                     .doc('Favorites')
//                                     .update({
//                                   'audios': FieldValue.arrayUnion([audioTitle])
//                                 });
//                                 setState(() {
//                                   tester = true;
//                                   likeNbr = likeNbr + 1;
//                                 });
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content:
//                                         Text('Correctely added to Favorites !'),
//                                     duration: Duration(seconds: 1),
//                                   ),
//                                 );
//                               }
//                             });
//                           }
//                         },
//                         icon: const Icon(
//                           Icons.favorite_border_outlined,
//                           color: Colors.white,
//                         ),
//                       )
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
