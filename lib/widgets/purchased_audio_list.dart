import 'package:audio_app_example/app_localizations.dart';
import 'package:audio_app_example/providers/language_notifier.dart';
import 'package:audio_app_example/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PurchasedAudiosList extends StatelessWidget {
  final List<String> audioIds;
  final AppLanguage lang;
  const PurchasedAudiosList(
      {Key? key, required this.audioIds, required this.lang})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (audioIds.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          AppLocalizations.tr('no_purchases', lang),
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: audioIds.length,
      itemBuilder: (context, index) {
        final audioId = audioIds[index];
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('Audios')
              .doc(audioId)
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return ListTile(
                title: Text(AppLocalizations.tr('error', lang)),
              );
            }
            final data = snapshot.data!.data() as Map<String, dynamic>;
            return ListTile(
              leading: Icon(Icons.headphones, color: pcolor),
              title: Text(data['Name'] ?? 'Untitled'),
              subtitle: Text(data['Author'] ?? ''),
            );
          },
        );
      },
    );
  }
}
