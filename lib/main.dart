import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:my_own_frashcards/db/database.dart';
import 'package:my_own_frashcards/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'model_theme.dart';
import 'style.dart';

late MyDatabase database;

void main() {
  database = MyDatabase();
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(MyApp());
}

class ThemeModeModel extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;

  set mode(ThemeMode mode) {
    _mode = mode;
    notifyListeners();
  }

  ThemeMode get mode => _mode;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (_) => ModelTheme(),
      child: Consumer<ModelTheme>(
        builder: (context, ModelTheme themeNotifier, child) {
          return MaterialApp(
            title: "シンプル単語帳",
            theme: themeNotifier.isDark
                ?darkTheme()
                :lightTheme(),
            home: HomeScreen(),
            debugShowCheckedModeBanner: false,
          );
        }
      ),
    );
  }
}
