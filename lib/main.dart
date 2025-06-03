import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:workshop_system/firebase_options.dart';
import 'package:provider/provider.dart'; // Import provider package
import 'package:go_router/go_router.dart';

// Import your services and repositories
import 'services/firestore_service.dart';
import 'services/auth_service.dart'; // Import AuthService
import 'repositories/user_repository.dart';
import 'repositories/foreman_repository.dart';
import 'repositories/workshop_repository.dart';
import 'models/app_user_model.dart'; // Import AppUser model
import 'config/router.dart'; // Import the router configuration

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        // Service Providers
        Provider<FirestoreService>(
          create: (_) => FirestoreService(),
        ),
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),

        // Repository Providers (dependent on FirestoreService)
        ProxyProvider<FirestoreService, UserRepository>(
          update: (context, firestoreService, previousUserRepository) =>
              UserRepository(firestoreService),
        ),
        ProxyProvider<FirestoreService, ForemanRepository>(
          update: (context, firestoreService, previousForemanRepository) =>
              ForemanRepository(firestoreService),
        ),
        ProxyProvider<FirestoreService, WorkshopRepository>(
          update: (context, firestoreService, previousWorkshopRepository) =>
              WorkshopRepository(firestoreService),
        ),
        
        // We will add ChangeNotifierProviders for ViewModels here later
      ],
      child: const MyApp(), // Your root application widget
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router, // Use the global router instance
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
