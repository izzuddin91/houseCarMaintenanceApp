import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iz_properties/property.dart';

class DashboardPage extends StatefulWidget {
  final String user_id;
  const DashboardPage({super.key, required this.user_id});

  @override
  State<StatefulWidget> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  var array = [];
  var test = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          children: [
            SizedBox(height: 50),
            Text(
              'Properties List',
              style: TextStyle(fontSize: 25),
            ),
            StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('houses')
                    .where('user_id', isEqualTo: widget.user_id)
                    .snapshots(),
                builder: (context, snapshot) {
                  List<Row> clientWidgets = [];
                  if (snapshot.hasData) {
                    final clients = snapshot.data?.docs.reversed.toList();
                    for (var client in clients!) {
                      final clientWidget = Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: const EdgeInsets.all(15.0),
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey)),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: ((context) => PropertyPage(
                                              houseId: client != null
                                                  ? client['houseId']
                                                  : '',
                                            ))));
                              },
                              child: Text(
                                client['houseName'],
                                style: TextStyle(fontSize: 20),
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
  }
}
