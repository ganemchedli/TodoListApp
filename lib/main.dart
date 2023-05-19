import 'package:provider/provider.dart';
import 'package:todolistv2/constraints/colors.dart';
import 'package:todolistv2/firebase_options.dart';
import 'package:todolistv2/screens/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: MaterialApp(
        title: 'ToDo List',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: tdBg),
          useMaterial3: true,
        ),
        home: const Home(),
      ),
    );
  }
}
