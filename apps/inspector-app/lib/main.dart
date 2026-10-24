import 'package:flutter/material.dart';
import 'features/inspections/presentation/screens/inspection_list_screen.dart';

void main() {
  runApp(const InspectorApp());
}

class InspectorApp extends StatelessWidget {
  const InspectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InspecOS — Inspector Técnico',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF1A73E8),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1A73E8),
          surface: Color(0xFF1E1E1E),
          secondary: Color(0xFF03DAC6),
          error: Color(0xFFCF6679),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF333333)),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A1A),
          elevation: 0,
        ),
      ),
      home: const InspectionListScreen(),
    );
  }
}
