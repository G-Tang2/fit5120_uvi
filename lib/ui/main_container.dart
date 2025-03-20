import 'package:flutter/material.dart';
import 'package:onboarding/pages/home_page.dart';
import 'package:onboarding/pages/settings_page.dart';

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
        color: Color(0xFF75BDE0),
        borderRadius: BorderRadius.circular(16)
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
    const SettingsPage(title: "Information Page")
  ];

  void _onPageSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // decoration: BoxDecoration(
        //   image: DecorationImage(
        //     image: AssetImage("images/background.jpeg"),
        //     fit: BoxFit.none,
        //     repeat: ImageRepeat.repeat
        //   ),
        // ),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(child: Container(
                    // color: Colors.blue.shade50
                    )),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 20,
                          // color: Colors.blue.shade50,
                        ),
                        WebNavbar(onItemSelected: _onPageSelected),
                        Container(
                          height: 20,
                          // color: Colors.blue.shade50,
                        ),
                        Expanded(
                          child: IndexedStack(
                            index: _selectedIndex,
                            children: _pages,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(child: Container(
                    // color: Colors.blue.shade50
                    )),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}
