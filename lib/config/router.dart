import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import '../views/auth/welcome_view.dart';
import '../views/auth/login_view.dart';
import '../views/auth/foreman_register_view.dart';
import '../views/auth/workshop_register_view.dart';

// Placeholder for home screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome! You are logged in.'),
            ElevatedButton(
              onPressed: () async {
                await Provider.of<AuthService>(context, listen: false).signOut();
                // ignore: use_build_context_synchronously
                if (!context.mounted) return;
                context.go('/welcome');
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      redirect: (BuildContext context, GoRouterState state) {
        final authService = Provider.of<AuthService>(context, listen: false);
        return authService.getCurrentUser() == null ? '/welcome' : '/home';
      },
    ),
    GoRoute(
      path: '/welcome',
      builder: (BuildContext context, GoRouterState state) {
        return const WelcomeView();
      },
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginView();
      },
    ),
    GoRoute(
      path: '/register/foreman',
      builder: (BuildContext context, GoRouterState state) {
        return const ForemanRegisterView();
      },
    ),
    GoRoute(
      path: '/register/workshop',
      builder: (BuildContext context, GoRouterState state) {
        return const WorkshopRegisterView();
      },
    ),
    GoRoute(
      path: '/home',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
    ),
  ],
);
