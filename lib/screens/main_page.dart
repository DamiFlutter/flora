import 'package:flora/providers/auth_providers.dart';
import 'package:flora/screens/home_screen.dart';
import 'package:flora/screens/profile_screen.dart';
import 'package:flora/screens/users_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  final PageController? _pageController = PageController();
  int _page = 0;
  List pages = [
    const HomeScreen(),
    const UserScreen(),
    const ProfileScreen(),
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Provider.of<AuthProvider>(context, listen: false).updateLastSeen(
    //   active: 'online',
    // );
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        Provider.of<AuthProvider>(context, listen: false).updateLastSeen(
          active: 'online',
        );
      });
      if (kDebugMode) {
        print('resumed');
      }
    } else if (state == AppLifecycleState.detached) {
      Provider.of<AuthProvider>(context, listen: false).updateLastSeen(
        active: 'offline',
      );
      if (kDebugMode) {
        print('detached');
      }
    } else if (state == AppLifecycleState.paused) {
      if (kDebugMode) {
        print('paused');
      }
      Provider.of<AuthProvider>(context, listen: false).updateLastSeen(
        active: 'offline',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
          itemCount: pages.length,
          controller: _pageController,
          onPageChanged: (page) {
            setState(() {
              _page = page;
            });
          },
          itemBuilder: ((context, index) {
            return pages[index];
          })),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        currentIndex: _page,
        showUnselectedLabels: false,
        iconSize: 16,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(FontAwesome.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(FlutterIcons.find_ant),
            label: 'Status',
          ),
          BottomNavigationBarItem(
            icon: Icon(FlutterIcons.user_fea),
            label: 'Home',
          ),
        ],
        onTap: (index) {
          _pageController?.animateToPage(index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.linearToEaseOut);
        },
      ),
    );
  }
}
