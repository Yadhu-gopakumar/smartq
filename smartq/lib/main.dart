import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartq/pages/loginpage.dart';
import 'pages/homepage.dart';
import 'pages/acountpage.dart';
import 'pages/orderpage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './provider/bottom_bar_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  if (await Permission.storage.request().isGranted)
 {
    print("Permission Granted!");
  } else {
    print("Permission Denied!");
  }
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestPermissions();
  final prefs = await SharedPreferences.getInstance();
  bool isAuthenticated =
      prefs.getString('token') != null; //Check token presence for authentiacte

  runApp(ProviderScope(child: MyApp(isAuthenticated: isAuthenticated)));
}

class MyApp extends StatelessWidget {
  final bool isAuthenticated;
  const MyApp({super.key, required this.isAuthenticated});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          color: Colors.yellow[800],
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: isAuthenticated ? const BottomBar() : LoginPage(),
    );
  }
}

class BottomBar extends ConsumerWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(bottomBarIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: const [HomePage(), OrderPage(), AccountPage()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) =>
            ref.read(bottomBarIndexProvider.notifier).state = index,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedItemColor: Colors.yellow[900],
        unselectedItemColor: Colors.grey[800],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}