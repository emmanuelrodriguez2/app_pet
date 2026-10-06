import 'package:dog_center/presentation/home/home_screen.dart';
import 'package:dog_center/presentation/home/provider/home_provider.dart';
import 'package:dog_center/presentation/login/login_screen.dart';
import 'package:dog_center/presentation/nutrition/nutrition_screen.dart';
import 'package:dog_center/presentation/profile/profile_screen.dart';
import 'package:dog_center/presentation/splash/splash_screen.dart';
import 'package:dog_center/presentation/sync/sync_screen.dart';
import 'package:dog_center/presentation/vision/vision_screen.dart';
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
          ProfileScreen.routeName: (_) => const ProfileScreen(),
        },
      ),
    );
  }
}
