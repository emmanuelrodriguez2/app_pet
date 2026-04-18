import 'package:app_pet/presentation/home/home_screen.dart';
import 'package:app_pet/presentation/home/provider/home_provider.dart';
import 'package:app_pet/presentation/login/login_screen.dart';
import 'package:app_pet/presentation/nutrition/nutrition_screen.dart';
import 'package:app_pet/presentation/splash/splash_screen.dart';
import 'package:app_pet/presentation/sync/sync_screen.dart';
import 'package:app_pet/presentation/vision/vision_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DogFoodCalculatorProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (_) => const PageOnboarding(),
          '/login': (_) => const LoginPage(),
          '/home': (_) => const HomeScreen(),
          NutritionScreen.routeName: (_) => const NutritionScreen(),
          VisionScreen.routeName: (_) => const VisionScreen(),
          SyncScreen.routeName: (_) => const SyncScreen(),
        },
      ),
    );
  }
}
