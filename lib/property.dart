import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:async';
import 'package:iz_properties/property_add_logs.dart';
import 'package:iz_properties/property_edit_logs.dart';
import 'package:path_provider/path_provider.dart';
import 'bloc/counter_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uri_to_file/uri_to_file.dart';
import 'package:http/http.dart' show get;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'bloc/house_log_bloc.dart';

const List<String> monthList = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December'
];

const List<String> monthListInteger = <String>[
  '01',
  '02',
  '03',
  '04',
  '05',
  '06',
  '07',
  '08',
  '09',
  '10',
  '11',
  '12'
];
const List<String> year = <String>['2023', '2024'];

class PropertyPage extends StatefulWidget {
  const PropertyPage({super.key, required this.houseId});

  final String houseId;
  @override
  State<StatefulWidget> createState() => _PropertyPageState();
}

class _PropertyPageState extends State<PropertyPage> {
  Future<File> file(String url) async {
    File file2 = new File('');
    try {
      String uriString = url; // Uri string

      // Don't pass uri parameter using [Uri] object via uri.toString().
      // Because uri.toString() changes the string to lowercase which causes this package to misbehave

      // If you are using uni_links package for deep linking purpose.
      // Pass the uri string using getInitialLink() or linkStream

      File file = await toFile(uriString); // Converting uri to file
      file2 = file;
    } catch (e) {
      print(e); // Exception
    }
    return file2;
  }

  Future<void> _showMyDialog(
      BuildContext context, CounterState state, CounterBloc counterBloc) async {
    String dropdownValue = monthList[state.month - 1 < 0
        ? 0
        : state.month - 1]; // list index start with zero, so minus 1
    String dropdownValue2 = state.year.toString();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('Select month / year'),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Row(
                    children: [
                      DropdownButton<String>(
                        value: dropdownValue,
                        icon: const Icon(Icons.arrow_downward),
                        elevation: 16,
                        style: const TextStyle(color: Colors.deepPurple),
                        underline: Container(
                          height: 2,
                          color: Colors.deepPurpleAccent,
                        ),
                        onChanged: (String? value) {
                          // This is called when the user selects an item.
                          setState(() {
                            dropdownValue = value!;
                            counterBloc.add(UpdateMonthEvent(
                                month: monthList.indexOf(value)));
                          });
                        },
                        items: monthList
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      DropdownButton<String>(
                        value: dropdownValue2,
                        icon: const Icon(Icons.arrow_downward),
                        elevation: 16,
                        style: const TextStyle(color: Colors.deepPurple),
                        underline: Container(
                          height: 2,
                          color: Colors.deepPurpleAccent,
                        ),
                        onChanged: (String? value) {
                          // This is called when the user selects an item.
                          setState(() {
                            dropdownValue2 = value!;
                            counterBloc
                                .add(UpdateYearEvent(year: int.parse(value)));
                          });
                        },
                        items:
                            year.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  )
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Search'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final CounterBloc counterBloc = BlocProvider.of<CounterBloc>(context);
    counterBloc.add(InitialLoadEvent());

    return BlocBuilder<CounterBloc, CounterState>(
      builder: (context, state) {
        var lessThanDate = '';
        var greaterThanDate = '';

        if (state.month == 11) {
          greaterThanDate = '${state.year}-12-01';
          lessThanDate = '${state.year + 1}-01-01';
        } else {
          greaterThanDate =
              '${state.year}-${((state.month) == 12 ? 11 : state.month) < 10 ? '0${state.month}' : state.month}-01';
          lessThanDate =
              '${(state.year)}-${((state.month + 1) < 10 ? '0${state.month + 1}' : state.month + 1)}-01';
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('House Logs'),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.calendar_month),
                tooltip: 'Show Snackbar',
                onPressed: () {
                  _showMyDialog(context, state, counterBloc);
                },
              ),
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Show Snackbar',
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) =>
                              PropertyAddLogs(houseId: widget.houseId))));
                },
              )
            ],
          ),
          body: Container(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: [
                SizedBox(height: 50),
                StreamBuilder<QuerySnapshot>(
                    // for example, user want to search 1st january until end of month
                    // we will miss 1st january, because it's greater than 1st jan
                    // so need to use this isGreaterThanOrEqualTo
                    stream: FirebaseFirestore.instance
                        .collection('houseLogs')
                        .where("houseId", isEqualTo: widget.houseId)
                        .where("date",
                            isGreaterThanOrEqualTo:
                                DateTime.parse(greaterThanDate))
                        .where("date", isLessThan: DateTime.parse(lessThanDate))
                        .snapshots(),
                    builder: (context, snapshot) {
                      List<Row> clientWidgets = [];
                      if (snapshot.hasData) {
                        final clients = snapshot.data?.docs.reversed.toList();

                        for (var client in clients!) {
                          final DateFormat formatter = DateFormat('MMMM dd');
                          final String formatted =
                              formatter.format(client['date'].toDate());
                          final clientWidget = Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    // print(client.data().doc);
                                    // convert image to file here
                                    EasyLoading.show(status: 'loading...');
                                    print('at home page');
                                    print(client.id);
                                    var response = await get(Uri.parse(client[
                                                'filename'] ==
                                            ''
                                        ? 'https://firebasestorage.googleapis.com/v0/b/housecarmaintenance.appspot.com/o/uploads%2Fwhite_screen.png?alt=media&token=5c686145-9311-4376-95c9-a56b07d93d2a'
                                        : client['filename'])); // <--2
                                    var documentDirectory =
                                        await getApplicationDocumentsDirectory();
                                    var firstPath =
                                        documentDirectory.path + "/images";
                                    var filePathAndName =
                                        documentDirectory.path +
                                            '/images/pic.jpg';

                                    await Directory(firstPath)
                                        .create(recursive: true); // <-- 1
                                    File file2 =
                                        new File(filePathAndName); // <-- 2
                                    file2.writeAsBytesSync(
                                        response.bodyBytes); // <--

                                    final HouseLogBloc houseLogBloc =
                                        BlocProvider.of<HouseLogBloc>(context);
                                    houseLogBloc.add(AddHouseLog(
                                        dateTime: client['date'].toDate(),
                                        description: client['notes'],
                                        amount: double.parse(
                                            client['total'].toString()),
                                        houseId: client.id,
                                        imageFile: file2));
                                    EasyLoading.dismiss();
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: ((context) =>
                                                PropertyEditLogs(
                                                  houseId: widget.houseId,
                                                  amount: double.parse(
                                                      client['total']
                                                          .toString()),
                                                  dateTime:
                                                      client['date'].toDate(),
                                                  description: client['notes'],
                                                  imageFile: file2,
                                                ))));
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.all(10.0),
                                    padding: const EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${formatted}: \n ${client['notes']} ',
                                          style: TextStyle(fontSize: 15),
                                        ),
                                        Text(
                                          'RM${client['total']}',
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          );
                          clientWidgets.add(clientWidget);
                        }
                      }
                      return Expanded(
                        child: ListView(
                          children: clientWidgets,
                        ),
                      );
                    })
              ],
            ),
          ),
        );
      },
    );
  }
}
