import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'screens/home_screen.dart';

void main() {
  if (kIsWeb) {
    // Fix for Flutter web keyboard assertion error
    WidgetsFlutterBinding.ensureInitialized();
  }
  runApp(const Gadgets360App());
}

class Gadgets360App extends StatelessWidget {
  const Gadgets360App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gadgets360',
      debugShowCheckedModeBanner: false,
      // Fix for Flutter web keyboard issues
      useInheritedMediaQuery: true,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            // Disable keyboard height adjustments on web to avoid assertion errors
            viewInsets: kIsWeb ? EdgeInsets.zero : null,
          ),
          child: child!,
        );
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE02020),
          brightness: Brightness.light,
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFE02020),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
