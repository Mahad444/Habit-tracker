import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_tracker/providers/habit_provider.dart';
import 'package:habit_tracker/screens/dashboard_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  await Hive.initFlutter();
  // Provider init will handle adapter registration and box opening
  final habitProvider = HabitProvider();
  await habitProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: habitProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
        primaryColor: const Color(0xFF38BDF8), // Sky 400
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF38BDF8),
          secondary: const Color(0xFF818CF8), // Indigo 400
          surface: const Color(0xFF1E293B), // Slate 800
          onSurface: Colors.white,
        ),
        textTheme: GoogleFonts.outfitTextTheme(
          Theme.of(context).textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
        ),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}
