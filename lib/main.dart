import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:login_app_demo/pages/dashboard_page_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
    apiKey: 'AIzaSyB5hJnoG6LNRjBthUrKAntE0T0BslPo5Xc',
    appId: '1:610213625650:android:5a1946b7550e9c3ddfe12b',
    projectId: 'demologinapp-58753',
    storageBucket: 'demologinapp-58753.firebasestorage.app',
    messagingSenderId: '610213625650',
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login App',
      home: DashboardPage(),
    );
  }
}
