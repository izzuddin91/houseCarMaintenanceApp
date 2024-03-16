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
import 'bloc/house_log_bloc.dart';

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
  List<Widget> fruits = <Widget>[
    Row(children: <Widget>[
      Icon(Icons.arrow_forward, size: 16.0, color: Colors.green),
      SizedBox(width: 6.0),
      Text('Revenue', style: TextStyle(color: Colors.green))
    ]),
    Row(children: <Widget>[
      Icon(Icons.arrow_back, size: 16.0, color: Colors.red[800]),
      SizedBox(width: 6.0),
      Text('Expenses', style: TextStyle(color: Colors.red[800]))
    ]),
  ];

  Future pickImage(HouseLogBloc bloc) async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    EasyLoading.show(status: 'uploading...');
    _selectedImage = File(returnedImage!.path);
    uploadFile(_selectedImage).then(
      (value) => {
        bloc.add(
            UpdateHouseLogImage(imageFile: _selectedImage, imageLink: value!)),
        EasyLoading.dismiss()
      },
    );
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
    bool vertical = false;

    return BlocBuilder<HouseLogBloc, HouseLogState>(
      builder: (context, state) {
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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Log Type',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      ToggleButtons(
                        direction: vertical ? Axis.vertical : Axis.horizontal,
                        onPressed: (int index) async {
                          List<bool> _selectedType = state.logType;
                          for (int i = 0; i < _selectedType.length; i++) {
                            _selectedType[i] = i == index;
                          }
                          setState(() {
                            houseLogBloc
                                .add(UpdateLogType(logType: _selectedType));
                          });
                        },
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        selectedBorderColor: Colors.blue[700],
                        selectedColor: Colors.white,
                        fillColor: Colors.blue[200],
                        color: Colors.blue[400],
                        constraints: BoxConstraints(
                            minHeight: 30,
                            minWidth:
                                (MediaQuery.of(context).size.width - 36) / 2),
                        isSelected: state.logType,
                        children: fruits,
                      ),
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
                      if (state.imageLink != '') Image.file(state.imageFile),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size.fromHeight(
                                40), // fromHeight use double.infinity as width and 40 is the height
                          ),
                          onPressed: () async {
                            pickImage(houseLogBloc);
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
                                    "filename": state.imageLink,
                                    "isRevenue": state.logType[0],
                                    "isExpenses": state.logType[1]
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
