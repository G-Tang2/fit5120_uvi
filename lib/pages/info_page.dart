import 'package:flutter/material.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> with SingleTickerProviderStateMixin{
  late TabController _tabController;

  final Map<String, String> images = {
    'gender': 'assets/lottie/v_gender.JPG',
    'age': 'assets/lottie/v_age.JPG',
  };

  final Map<String, List<List<String>>> imageData = {
    'gender': [
      ['Gender', 'Incidence', 'Mortality'],
      ['Females', '199,205', '18,871'],
      ['Males', '228,256', '32,281'],
    ],
    'age': [
      ['Age Group', 'Incidence', 'Mortality'],
      ['0-14', '1,034', '32'],
      ['15-30', '37,192', '1,482'],
      ['31-45', '115,820', '7,258'],
      ['46-60', '158,136', '16,206'],
      ['61-75', '147,261', '29,616'],
      ['76-90', '115,919', '30,956'],
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildContent(String type) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            elevation: 5,
            margin: const EdgeInsets.all(20.0),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Image.asset(images[type]!, fit: BoxFit.contain),
                  
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: imageData[type]![0]
                    .map((header) => DataColumn(label: Text(header)))
                    .toList(),
                rows: imageData[type]!
                    .sublist(1)
                    .map((row) => DataRow(
                          cells: row
                              .map((cell) => DataCell(Text(cell)))
                              .toList(),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Data Information about UV impact"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'By Gender'),
            Tab(text: 'By Age'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildContent('gender'),
          _buildContent('age'),
        ],
      ),
      // body: Center(
      //   // Center is a layout widget. It takes a single child and positions it
      //   // in the middle of the parent.
      //   child: Column(
      //     // Column is also a layout widget. It takes a list of children and
      //     // arranges them vertically. By default, it sizes itself to fit its
      //     // children horizontally, and tries to be as tall as its parent.
      //     //
      //     // Column has various properties to control how it sizes itself and
      //     // how it positions its children. Here we use mainAxisAlignment to
      //     // center the children vertically; the main axis here is the vertical
      //     // axis because Columns are vertical (the cross axis would be
      //     // horizontal).
      //     //
      //     // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
      //     // action in the IDE, or press "p" in the console), to see the
      //     // wireframe for each widget.
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: <Widget>[
      //       const Text('This is the Information Page'),
      //     ],
      //   ),
      // ),
    );
  }
}