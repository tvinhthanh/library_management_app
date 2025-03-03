import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'providers/user_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
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
      debugShowCheckedModeBanner: false,
      title: 'Quản lý thư viện',
      theme: AppTheme.lightTheme, // Sử dụng theme từ core/theme
      home: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return userProvider.isLoggedIn ? const HomeScreen() : const LoginScreen();
        },
      ),
    );
  }
}
