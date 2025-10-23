//page to upload files, launched when the user press the button in the account section
import 'package:audio_app_example/Services-old/storage.dart';
import 'package:audio_app_example/main.dart';
import 'package:audio_app_example/models/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'models/user.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

//works similarely as the email login file
final title = TextEditingController();
final description = TextEditingController();
bool loading = false;
//items for the multichoice
List<Item> items = [
  Item(id: 1, name: "News"),
  Item(id: 2, name: "Learning"),
  Item(id: 3, name: "Entertain"),
];
List<Item> _selectedItems = [];

//see email login file for more comments
class Up extends StatefulWidget {
  const Up({Key? key}) : super(key: key);

  @override
  Upload createState() => Upload();
}

class Upload extends State<Up> {
  final StorageService store = StorageService();
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser?>(context);
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;
    return loading
        //allows to return the loading widget when the file is beeing uploded
        ? const Loading()
        : Scaffold(
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
                  title.text = '';
                  description.text = '';
                  Navigator.pop(context);
                },
              ),
            ),
            backgroundColor: bcolor,
            //front end details
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(
                      vertical: width * 0.1,
                      horizontal: width * 0.0875,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Upload your file",
                          style: GoogleFonts.poppins(
                            color: tcolor,
                            fontSize: width * 0.0625,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: width * 0.0375),
                      ],
                    ),
                  ),
                  SizedBox(height: width * 0.0625),
                  const UploadForm(),
                  SizedBox(height: width * 0.0875),
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: width * 0.225,
                    ),
                    //multi choice to put the audio in one or several playlist (corresponding ton the playlists from the home page)
                    child: MultiSelectDialogField(
                      dialogHeight: height * 0.25,
                      //items from the list at the to of the file
                      items:
                          items.map((e) => MultiSelectItem(e, e.name)).toList(),
                      buttonText: Text(
                        "Corresponding playlists",
                        style: GoogleFonts.poppins(
                          color: Colors.grey[400],
                        ),
                      ),
                      buttonIcon:
                          Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
                      title: const Text("Playlists"),
                      selectedColor: Colors.grey,
                      onConfirm: (values) => _selectedItems = values,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                      vertical: width * 0.175,
                      horizontal: width * 0.225,
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        //seek for the author name
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          await FirebaseFirestore.instance
                              .collection('Users')
                              .get();
                          DocumentSnapshot<Map<String, dynamic>> theuser =
                              await FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(user.uid)
                                  .get();
                          Map<String, dynamic> data =
                              theuser.data() as Map<String, dynamic>;
                          String selected = '';
                          //creats a String containing the playlists
                          for (var item in _selectedItems) {
                            selected = '$selected ${item.name}';
                          }
                          print(selected);
                          //enables to select a file
                          final res = await FilePicker.platform.pickFiles(
                            allowMultiple: false,
                            type: FileType.custom,
                            //only images
                            allowedExtensions: ['png', 'jpeg', 'heic', 'heif'],
                          );
                          if (res == null) {
                            //warns the user if no file was selected
                            showDialog(
                              context: context,
                              builder: (context) {
                                return const AlertDialog(
                                  content: Text('No file selected'),
                                );
                              },
                            );
                            return;
                          }
                          //warns the user to select an audio
                          await showDialog(
                            context: context,
                            builder: (context) {
                              return const AlertDialog(
                                content: Text('Now, select the audio file'),
                              );
                            },
                          );
                          final result = await FilePicker.platform.pickFiles(
                            allowMultiple: false,
                            type: FileType.custom,
                            //only mp3 files allowed
                            allowedExtensions: ['mp3'],
                          );
                          if (result == null) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return const AlertDialog(
                                  content: Text('No file selected'),
                                );
                              },
                            );
                            return;
                          } else {
                            //gets the files for the image
                            final way = res.files.single.path!;
                            setState(() => loading = true);
                            //store the file in the database and set the display the loading widget
                            await store.uploadPicture(way, title.text);
                            setState(() => loading = false);
                            //gets the file for the audio
                            final path = result.files.single.path!;
                            setState(() => loading = true);
                            //store the file in the database and set the display the loading widget
                            await store.uploadFile(path, data['Name'],
                                title.text, description.text, selected);
                            //stop the displaying of the loading
                            setState(() => loading = false);
                            title.text = '';
                            description.text = '';
                            Navigator.pop(context);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(), backgroundColor: pcolor,
                        padding: EdgeInsets.all(0.05 * width),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'SELECT PICTURE',
                            style: GoogleFonts.poppins(
                              color: tcolor,
                              fontSize: width * 0.035,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: width * 0.05),
                ],
              ),
            ),
          );
  }
}

//form like the email login page
class UploadForm extends StatefulWidget {
  const UploadForm({super.key});

  @override
  _UploadFormState createState() => _UploadFormState();
}

class _UploadFormState extends State<UploadForm> {
  final _obscureText = true;
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var height = size.height;
    var width = size.width;
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: width * 0.0875,
      ),
      child: Column(
        children: [
          TextField(
            style: TextStyle(color: tcolor),
            controller: title,
            decoration: InputDecoration(
              labelText: 'The podcast title',
              labelStyle: TextStyle(
                color: Colors.grey[400],
              ),
            ),
          ),
          SizedBox(height: width * 0.0475),
          TextField(
            style: TextStyle(color: tcolor),
            controller: description,
            decoration: InputDecoration(
              labelStyle: TextStyle(
                color: Colors.grey[400],
              ),
              labelText: 'The podcast description',
            ),
          ),
        ],
      ),
    );
  }
}

//class for the item of the multi select
class Item {
  final int id;
  final String name;

  Item({
    required this.id,
    required this.name,
  });
}
