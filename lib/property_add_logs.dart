import 'dart:io';
import 'dart:io' as io;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PropertyAddLogs extends StatefulWidget {
  const PropertyAddLogs({super.key, required this.houseId});

  final String houseId;
  @override
  State<StatefulWidget> createState() => _PropertyAddLogsState();
}

class _PropertyAddLogsState extends State<PropertyAddLogs> {
  File _selectedImage = new File('');
  final _formKey = GlobalKey<FormState>();
  DateTime selectedDate = new DateTime.now();
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  List<UploadTask> _uploadTasks = [];

  Future pickImage() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      _selectedImage = File(returnedImage!.path);
    });
  }

  /// The user selects a file, and the task is added to the list.
  Future<UploadTask?> uploadFile(File? file) async {
    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No file was selected'),
        ),
      );

      return null;
    }

    UploadTask uploadTask;

    // Create a Reference to the file
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('flutter-tests')
        .child('/some-image.jpg');

    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {'picked-file-path': file.path},
    );

    // if (kIsWeb) {
    //   uploadTask = ref.putData(await file.readAsBytes(), metadata);
    // } else {
    //   uploadTask = ref.putFile(io.File(file.path), metadata);
    // }
    uploadTask = ref.putFile(io.File(file.path), metadata);
    return Future.value(uploadTask);
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
                      // print('selected date is ${val}');
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
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // push image first
                          // Create a Reference to the file
                          String downloadUrl = '';
                          Reference ref = FirebaseStorage.instance
                              .ref()
                              .child('flutter-tests')
                              .child('/some-image.jpg');
                          uploadFile(_selectedImage).then((uploadTask) => {
                                uploadTask!.snapshot.ref
                                    .getDownloadURL()
                                    .then((value) => {
                                          setState(
                                            () {
                                              print(value);
                                              downloadUrl = value;
                                            },
                                          )
                                        })
                              });
                          print('object');
                          print(downloadUrl);
                          final metadata = SettableMetadata(
                            contentType: 'image/jpeg',
                            customMetadata: {
                              'picked-file-path': _selectedImage.path
                            },
                          );

                          print('valid');
                          // try push to firebase
                          // final docTodo = await FirebaseFirestore.instance
                          //     .collection('houseLogs')
                          //     .doc(widget.houseId);
                          // print(docTodo);
                          // docTodo
                          //     .set({
                          //       "notes": controller1.text,
                          //       "total": controller2.text,
                          //       "date": selectedDate
                          //     })
                          //     .onError(
                          //         (e, _) => print("Error writing document: $e"))
                          //     .then((value) => print('complete'));
                        }
                      },
                      child: const Text('Submit'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: ElevatedButton(
                      onPressed: () async {
                        pickImage();
                      },
                      child: const Text('Select Image'),
                    ),
                  ),
                ],
              ),
            )),
          ),
        ));
  }
}
