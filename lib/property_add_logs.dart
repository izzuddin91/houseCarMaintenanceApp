import 'dart:io';
import 'dart:io' as io;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gif_view/gif_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PropertyAddLogs extends StatefulWidget {
  const PropertyAddLogs({super.key, required this.houseId});

  final String houseId;
  @override
  State<StatefulWidget> createState() => _PropertyAddLogsState();
}

class _PropertyAddLogsState extends State<PropertyAddLogs> {
  final controller = GifController();
  File _selectedImage = new File('');
  final _formKey = GlobalKey<FormState>();
  DateTime selectedDate = new DateTime.now();
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  String downloadUrl = '';
  String imageUploadButton = 'Select image (optional)';

  Future pickImage() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      EasyLoading.show(status: 'loading...');
      _selectedImage = File(returnedImage!.path);
      uploadFile(_selectedImage).then(
        (value) => {
          setState(() {
            EasyLoading.dismiss();
            imageUploadButton = 'Upload complete ! you can now submit';
          }),
          downloadUrl = value!,
        },
      );
    });
  }

  /// The user selects a file, and the task is added to the list.
  Future<String?> uploadFile(File? file) async {
    String returnVal = '';
    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No file was selected'),
        ),
      );

      return null;
    }

    // Create a Reference to the file
    Reference ref = FirebaseStorage.instance.ref().child('uploads').child(
        '/${widget.houseId}_${selectedDate}.jpg'); // combine house id and date

    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {'picked-file-path': file.path},
    );

    await ref.putFile(io.File(file.path), metadata).then(
      (p0) async {
        await p0.ref.getDownloadURL().then((value) => {returnVal = value});
      },
    );
    return returnVal;
  }

  String? _validateField(String? value) {
    return value!.isEmpty ? '*Required Field' : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add House Logs'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
                child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DatePicker(
                    splashRadius: 10,
                    centerLeadingDate: true,
                    minDate: DateTime(2023, 10, 10),
                    maxDate: DateTime(2024, 12, 31),
                    onDateSelected: (val) {
                      selectedDate = val;
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: TextFormField(
                      validator: (value) => _validateField(value),
                      controller: controller1,
                      decoration: InputDecoration(
                        hintStyle: TextStyle(fontSize: 17),
                        hintText: 'Enter description',
                        suffixIcon: Icon(Icons.note),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(20),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: TextFormField(
                      validator: (value) => _validateField(value),
                      keyboardType: TextInputType.number,
                      controller: controller2,
                      decoration: InputDecoration(
                        hintStyle: TextStyle(fontSize: 17),
                        hintText: 'Enter Amount',
                        suffixIcon: Icon(Icons.price_change),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(20),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Image.file(_selectedImage),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(
                            40), // fromHeight use double.infinity as width and 40 is the height
                      ),
                      onPressed: () async {
                        setState(() {
                          imageUploadButton = 'Uploading . please wait..';
                        });
                        pickImage();
                      },
                      child: Text(imageUploadButton),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.fromHeight(
                            40), // fromHeight use double.infinity as width and 40 is the height
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // try push to firebase
                          final docTodo = await FirebaseFirestore.instance
                              .collection('houseLogs')
                              .doc();

                          docTodo
                              .set({
                                "notes": controller1.text,
                                "total": controller2.text,
                                "date": selectedDate,
                                "houseId": widget.houseId,
                                "filename": downloadUrl
                              })
                              .onError(
                                  (e, _) => print("Error writing document: $e"))
                              .then((value) => Navigator.of(context).pop());
                        }
                      },
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            )),
          ),
        ));
  }
}
