import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:date_picker_plus/date_picker_plus.dart';

class PropertyAddLogs extends StatefulWidget {
  const PropertyAddLogs({super.key, required this.houseId});

  final String houseId;
  @override
  State<StatefulWidget> createState() => _PropertyAddLogsState();
}

class _PropertyAddLogsState extends State<PropertyAddLogs> {
  final _formKey = GlobalKey<FormState>();
  DateTime selectedDate = new DateTime.now();
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();

  String? _validateField(String? value) {
    return value!.isEmpty ? '*Required Field' : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add House Logs'),
        ),
        body: Padding(
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        print('valied');
                        // try push to firebase
                        final docTodo = await FirebaseFirestore.instance
                            .collection('houseLogs')
                            .doc(widget.houseId);
                        print(docTodo);
                        docTodo
                            .set({
                              "notes": controller1.text,
                              "total": controller2.text,
                              "date": selectedDate
                            })
                            .onError(
                                (e, _) => print("Error writing document: $e"))
                            .then((value) => print('complete'));
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          )),
        ));
  }
}
