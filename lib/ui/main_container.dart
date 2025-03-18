import 'package:flutter/material.dart';
import 'package:onboarding/pages/home_page.dart';
import 'package:onboarding/pages/info_page.dart';
// import 'package:onboarding/pages/settings_page.dart';

// class MainContainer extends StatefulWidget {
//   const MainContainer({super.key});

//   @override
//   State<MainContainer> createState() => _MainContainerState();
// }

// class _MainContainerState extends State<MainContainer> {
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//   // int _selectedIndex = 0;

//   // final List<Widget> _pages = [
//   //   HomePage(title: "Home Page"),
//   //   InfoPage(title: "Info Page"),
//   //   // SettingsPage(title: "Settings Page"),
//   // ];

//   // void _onItemTapped(int index) {
//   //   setState(() {
//   //     _selectedIndex = index;
//   //   });
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // body: IndexedStack(
//       //   index: _selectedIndex,
//       //   children: _pages,
//       // ),
//       appBar: AppBar(
//         title: const Text("My App"),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [
//             Tab(icon: Icon(Icons.home), text: "Home"),
//             Tab(icon: Icon(Icons.info), text: "Info"),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: const [
//           HomePage(title: "Home Page"),
//           InfoPage(title: "Info Page"),
//         ],
//       ),
//       // bottomNavigationBar: BottomNavigationBar(
//       //   currentIndex: _selectedIndex,
//       //   onTap: _onItemTapped,
//       //   items: const [
//       //     BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//       //     BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Info'),
//       //     // BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
//       //   ],
//       // ),
//     );
//   }
// }
class WebNavbar extends StatefulWidget {
  final Function(int) onItemSelected;

  const WebNavbar({super.key, required this.onItemSelected});

  @override
  State<WebNavbar> createState() => _WebNavbarState();
}

class _WebNavbarState extends State<WebNavbar> {
  int _selectedIndex = 0;

  final List<String> _menuItems = ["Home", "Information"];

  void _onMenuTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onItemSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
      children: [
        const Text(
          "🌞 UVFind",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
          ),
        ),

        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end, 
            children: List.generate(_menuItems.length, (index) {
              return GestureDetector(
                onTap: () => _onMenuTap(index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    _menuItems[index],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          _selectedIndex == index
                              ? FontWeight.bold
                              : FontWeight.normal,
                      color:
                          _selectedIndex == index
                              ? Colors.deepOrange
                              : Colors.black87,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
      ),
    );
  }
}

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(title: "Home Page"),
    const InfoPage(title: "Info Page"),
  ];

  void _onPageSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // WebNavbar(onItemSelected: _onPageSelected),
          Expanded(
            child: Row(
              children: [
                Expanded(child: Container(color: Colors.blue.shade50)),

                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      WebNavbar(onItemSelected: _onPageSelected),
                      Expanded(
                        child: IndexedStack(
                          index: _selectedIndex,
                          children: _pages,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(child: Container(color: Colors.blue.shade50)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
