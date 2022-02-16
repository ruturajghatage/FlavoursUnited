import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flavours_united/components/video_item.dart';
import 'package:flavours_united/constants.dart';
import 'package:flavours_united/screens/video_playing_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flavours_united/storage_services/storage_service.dart';
import 'package:video_player/video_player.dart';
import 'package:flavours_united/storage_services/storage_service_guitar.dart';

import '../video_magnifier.dart';

FirebaseStorage storage = FirebaseStorage.instance;
final _fire = FirebaseFirestore.instance.collection('guitarURL');

class GuitarScreen extends StatefulWidget {
  static String id = 'guitar_screen';
  @override
  _GuitarScreenState createState() => _GuitarScreenState();
}

class _GuitarScreenState extends State<GuitarScreen> {
  @override
  Widget build(BuildContext context) {
    final StorageG storage = StorageG('guitar');
    return Scaffold(
      appBar: kAppBar,
      body: Column(
        children: [
          MessageStream(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final results =
              await FilePicker.platform.pickFiles(allowMultiple: false);

          if (results == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No file selected'),
              ),
            );
            return null;
          }

          final path = results.files.single.path!;
          final fileName = results.files.single.name;

          storage.uploadFile(path, fileName).then(
                (value) => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('File Uploaded'),
                  ),
                ),
              );
        },
        child: Icon(Icons.cloud_upload_sharp),
        backgroundColor: Colors.deepOrange,
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _fire.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text('Loading.....');
        }

        return Flexible(
          child: ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;

              return Padding(
                padding: EdgeInsets.all(10.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.orangeAccent,
                  ),
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      VideoItem(
                        data['guitar'],
                      ),
                      Container(
                        alignment: Alignment.bottomRight,
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoPlayingScreen(
                                VideoItem(
                                  data['guitar'],
                                ),
                              ),
                            ),
                          ),
                          child: Icon(
                            Icons.fullscreen,
                            color: Colors.black,
                            size: 35.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
