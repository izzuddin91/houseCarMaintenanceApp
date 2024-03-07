import 'dart:async';
import 'dart:io';
import 'dart:io' as io;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gif_view/gif_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:iz_properties/bloc/house_log_bloc.dart';

class PropertyEditLogs extends StatefulWidget {
  const PropertyEditLogs({
    super.key,
    required this.houseId,
    required this.dateTime,
    required this.description,
    required this.amount,
    required this.imageFile,
  });
  final DateTime dateTime;
  final String description;
  final double amount;
  final String houseId;
  final File imageFile;
  @override
  State<StatefulWidget> createState() => _PropertyEditLogsState();
}

class _PropertyEditLogsState extends State<PropertyEditLogs> {
  final controller = GifController();
  File _selectedImage = new File('');
  final _formKey = GlobalKey<FormState>();
  DateTime selectedDate = new DateTime.now();
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  String downloadUrl = '';
  String imageUploadButton = 'Select image (optional)';

  Future pickImage(HouseLogBloc houseLogBloc) async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    houseLogBloc.add(UpdateHouseLogImage(imageFile: File(returnedImage!.path)));
    setState(() {
      _selectedImage = File(returnedImage!.path);
      uploadFile(_selectedImage).then(
        (value) => {
          setState(() {
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
    final HouseLogBloc houseLogBloc = BlocProvider.of<HouseLogBloc>(context);

    return BlocBuilder<HouseLogBloc, HouseLogState>(
      builder: (context, state) {
        controller1.text = state.description;
        controller2.text = state.amount.toString();
        // _selectedImage = state.imageFile;
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
                        initialDate: state.dateTime,
                        selectedDate: state.dateTime,
                        splashRadius: 10,
                        centerLeadingDate: true,
                        minDate: DateTime(2021, 10, 10),
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
                      // Image.file(state.imageFile),
                      Image.memory(
                        state.imageFile.readAsBytesSync(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              imageUploadButton = 'Uploading . please wait..';
                            });
                            pickImage(houseLogBloc);
                          },
                          child: Text(imageUploadButton),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              // try push to firebase
                              final docTodo = await FirebaseFirestore.instance
                                  .collection('houseLogs')
                                  .doc(widget.houseId);

                              docTodo
                                  .update({
                                    "notes": controller1.text,
                                    "total": controller2.text,
                                    "date": selectedDate,
                                    "houseId": widget.houseId,
                                    "filename": downloadUrl
                                  })
                                  .onError((e, _) =>
                                      print("Error writing document: $e"))
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
      },
    );
  }
}
