//widget that pop when the user choose to add a note to an audio
import 'package:audio_app_example/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class NoteDialog extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final bool ex;

//requires the current audioPlayer and the bool ex to know if the audio has already a note or note
  const NoteDialog({Key? key, required this.audioPlayer, required this.ex})
      : super(key: key);

  @override
  _NoteDialogState createState() => _NoteDialogState();
}

class _NoteDialogState extends State<NoteDialog> {
  String note = '';
  Duration? time;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      //front end details
      title: const Text('Add a Note'),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            TextField(
              onChanged: (value) => note = value,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: pcolor),
                ),
                labelText: 'Note',
                labelStyle: const TextStyle(
                  color: Colors.black,
                ),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Time:',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                //retrieve the current audio position to register the note at the good timing
                StreamBuilder<Duration>(
                  stream: widget.audioPlayer.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    time = position;
                    return Text(
                      //casts the audio time
                      '${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            (widget.ex)
                //update the currente note if it exiists
                ? FirebaseFirestore.instance
                    .collection('Users')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .collection('Notes')
                    .doc(audioTitle)
                    .update({
                    //add the value if it is differents from the ones existing
                    'notes': FieldValue.arrayUnion(
                        ["${"$time".substring(2, 7)} - $note"])
                  })
                //creat a new note if it doesn't exists
                : FirebaseFirestore.instance
                    .collection('Users')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .collection('Notes')
                    .doc(audioTitle)
                    .set({
                    'notes': FieldValue.arrayUnion(
                        ["${"$time".substring(2, 7)} - $note"])
                  });
            Navigator.of(context).pop();
          },
          child: const Text(
            'Save',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
