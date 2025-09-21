import 'package:flutter/material.dart';
import 'login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String supabaseURL = 'https://qaecbfihjfzngpmgnhrw.supabase.co';
const String supabaseKey = 'sb_secret_8-_9ryPN6PKVuEg8os-uGQ_BGwA-cXt';

Future <void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseURL, anonKey: supabaseKey);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const PitStopApp(),
    );
  }
}
