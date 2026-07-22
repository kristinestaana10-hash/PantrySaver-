import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pantrysaver/firebase_options.dart';
import 'package:pantrysaver/providers/app_provider.dart';
import 'package:pantrysaver/screens/splash_screen.dart';
import 'package:pantrysaver/widgets/shared/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const PantrySaverApp());
}

class PantrySaverApp extends StatelessWidget {
  const PantrySaverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: Consumer<AppProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'PantrySaver',
            themeMode: provider.darkMode ? ThemeMode.dark : ThemeMode.light,
            theme: PantryAppTheme.lightTheme(),
            darkTheme: PantryAppTheme.darkTheme(),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}