import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';

import 'bloc/counter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

// DropdownButton<String>(
//   value: dropdownValue,
//   icon: const Icon(Icons.arrow_downward),
//   elevation: 16,
//   style: const TextStyle(color: Colors.deepPurple),
//   underline: Container(
//     height: 2,
//     color: Colors.deepPurpleAccent,
//   ),
//   onChanged: (String? value) {
//     // This is called when the user selects an item.
//     setState(() {
//       dropdownValue = value!;
//     });
//   },
//   items: list.map<DropdownMenuItem<String>>((String value) {
//     return DropdownMenuItem<String>(
//       value: value,
//       child: Text(value),
//     );
//   }).toList(),
// )

class _PropertyPageState extends State<PropertyPage> {
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
            title: Text('${state.year} / ${state.month}'),
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
        print(state.month);
        var lessThanDate = '';
        var greaterThanDate = '';

        if (state.month == 11) {
          greaterThanDate = '${state.year}-12-01';
          lessThanDate = '${state.year + 1}-01-01';
        } else {
          lessThanDate =
              '${(state.year)}-${monthListInteger[(state.month) + 1]}-01';
          greaterThanDate =
              '${state.year}-${monthListInteger[(state.month == 12 ? 11 : state.month)]}-01';
        }
        print('xx');
        print(greaterThanDate);
        print(lessThanDate);
        return Scaffold(
          appBar: AppBar(
            title: Text(
                'House Logs: ${state.month == 0 ? '1' : state.month} /  ${state.year}'),
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
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //     const SnackBar(content: Text('This is a snackbar')));
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
                    stream: FirebaseFirestore.instance
                        .collection('houseLogs')
                        .where("houseId", isEqualTo: widget.houseId)
                        .where("date",
                            isGreaterThan: DateTime.parse(greaterThanDate))
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
                                  onTap: () {
                                    // Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: ((context) =>
                                    //             const PropertyPage())));
                                  },
                                  child:
                                      // ListTile(
                                      //   leading: Text(formatted),
                                      //   title: Text(client['notes']),
                                      //   trailing: Text(client['total'].toString()),
                                      // )
                                      Container(
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
