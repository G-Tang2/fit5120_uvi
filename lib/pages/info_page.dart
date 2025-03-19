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
    return 
    Column(
        children: [
          Container(
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            color: Color(0xFFFFE3B3)
          ),
          child: Card(
            elevation: 5,
            color: Color(0xFFFFE3B3),
            margin: const EdgeInsets.all(20.0),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Image.asset(images[type]!),
                ],
                ),
              ),
            ),
          ),
          // Expanded(child:Container(color: Colors.blue.shade50,))
        ],
    );
  }

  @override
  Widget build(BuildContext context) {

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Scaffold(
      appBar: AppBar(
        title: Text("Data Information about UV impact"),
        centerTitle: true,
        backgroundColor: Color(0xFFF8BC9B).withValues(alpha: 0.8),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Color(0xFFF89B9B),
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
      ),)
    );
  }
}