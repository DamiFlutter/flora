import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flora/providers/auth_providers.dart';
import 'package:flora/providers/chat_providers.dart';
import 'package:flora/screens/home_screen.dart';
import 'package:flora/screens/login_screen.dart';
import 'package:flora/screens/main_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider(FirebaseAuth.instance)),
    Provider<ChatProvider>(
        create: (_) =>
            ChatProvider(firebaseFirestore: FirebaseFirestore.instance)),
    StreamProvider(
      create: (context) => context.read<AuthProvider>().authStateChanges,
      initialData: null,
    ),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();

    if (firebaseUser != null) {
      //If the user is successfully Logged-In.
      return const MainPage();
    } else {
      //If the user is not Logged-In.
      return const LoginScreen();
    }
  }
}
