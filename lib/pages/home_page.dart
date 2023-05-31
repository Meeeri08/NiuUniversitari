import 'package:flutter/material.dart';
import 'package:jobapp/pages/account_page.dart';
import 'package:jobapp/pages/add_house.dart';
import 'package:jobapp/pages/dashboard.dart';
import 'package:jobapp/pages/tinder.dart';
import 'messages_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentTab = 0;
  final List<Widget> screens = [
    Dashboard(),
    const Tinder(),
    const Messages(),
    const Account(),
  ];
  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = Dashboard();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        child: currentScreen,
        bucket: bucket,
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.add,
          size: 32,
        ),
        backgroundColor: const Color(0xFF1FA29E),
        shape: RoundedRectangleBorder(
          side: const BorderSide(
              color: Colors.white,
              width: 3,
              strokeAlign: BorderSide.strokeAlignCenter),
          borderRadius: BorderRadius.circular(50),
        ),
        elevation: 1,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddHousePage()),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        shadowColor: Colors.white,
        child: Container(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              MaterialButton(
                minWidth: 40,
                onPressed: () {
                  setState(() {
                    currentScreen = Dashboard();
                    currentTab = 0;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.home,
                      color: currentTab == 0
                          ? const Color(0xFF1FA29E)
                          : Colors.grey.shade300,
                    ),
                  ],
                ),
              ),
              MaterialButton(
                minWidth: 40,
                onPressed: () {
                  setState(() {
                    currentScreen = const Tinder();
                    currentTab = 1;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite,
                      color: currentTab == 1
                          ? const Color(0xFF1FA29E)
                          : Colors.grey.shade300,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 40),
              MaterialButton(
                minWidth: 40,
                onPressed: () {
                  setState(() {
                    currentScreen = const Messages();
                    currentTab = 2;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.message_outlined,
                      color: currentTab == 2
                          ? const Color(0xFF1FA29E)
                          : Colors.grey.shade300,
                    ),
                  ],
                ),
              ),
              MaterialButton(
                minWidth: 40,
                onPressed: () {
                  setState(() {
                    currentScreen = const Account();
                    currentTab = 3;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person,
                      color: currentTab == 3
                          ? const Color(0xFF1FA29E)
                          : Colors.grey.shade300,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
