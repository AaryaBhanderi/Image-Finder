
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:facefinalscan/features/user_auth/presentation/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
final CollectionReference _items =
FirebaseFirestore.instance.collection("Upload_Items");
Uint8List? image;
String imageUrl = '';
class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    double hit = MediaQuery.of(context).size.height;
    double wid = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Face Recognization'),
        actions: [GestureDetector(onTap: () {
          FirebaseAuth.instance.signOut();
          GoogleSignIn().signOut();
          Get.offAll(LoginPage()
          );
        },child: Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Icon(Icons.exit_to_app,color: Colors.red,),
        ))],
      ),
      body: Container(
        height: hit,
        width: wid,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Click to add Image',
              style: TextStyle(  color:Colors.black,fontWeight: FontWeight.bold,fontSize: 20),
            ),
            Icon(Icons.arrow_downward,color: Colors.black,),
            const Gap(5),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: GestureDetector(
                onTap: () async {
                  final file = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (file == null) return;

                  String fileName =
                  DateTime.now().microsecondsSinceEpoch.toString();

                  // Get the reference to storage root
                  // We create the image folder first and insider folder we upload the image
                  Reference referenceRoot =
                  FirebaseStorage.instance.ref();
                  Reference referenceDireImages =
                  referenceRoot.child('images');

                  // we have creata reference for the image to be stored
                  Reference referenceImageaToUpload =
                  referenceDireImages.child(fileName);

                  // For errors handled and/or success
                  try {
                    await referenceImageaToUpload
                        .putFile(File(file.path));

                    // We have successfully upload the image now
                    // make this upload image link in firebase database

                    imageUrl =
                        await referenceImageaToUpload.getDownloadURL();
                  } catch (error) {
                    //some error
                  }
                },
                child: Container(
                  height: 340,
                  width: 340,
                  decoration: BoxDecoration(
                    color:Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: (image == null)
                      ? Image.network(
                      'https://cdn-icons-png.flaticon.com/512/1309/1309762.png')
                      : Image.memory(
                    image!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const Gap(20),
            GestureDetector(
              onTap: () async {
                if (imageUrl.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              "Please select and upload image")));
                  return;
                }
              },
              child: Container(
                height: 50,
                width: 180,
                decoration: BoxDecoration(
                  color:Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Add Image',
                  style: TextStyle(  color:Colors.white,fontWeight: FontWeight.bold,fontSize: 20),
                ),
              ),
            ),
            const Gap(20),
            GestureDetector(
              onTap: () {
                Get.snackbar('Note', 'This method is deprecated');
              },
              child: Container(
                height: 50,
                width: 180,
                decoration: BoxDecoration(
                  border: Border.all(  color:Colors.black,),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Scan Face',
                  style: TextStyle(  color:Colors.black,fontWeight: FontWeight.bold,fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );

  }
  Future _pickImageFromGallery() async {
    final returnImage =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnImage == null) return;
    setState(() {
      var selectedImage = File(returnImage.path);
      image = File(returnImage.path).readAsBytesSync();
    });
  }

}
