import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:workshop_system/firebase_options.dart';
import 'package:provider/provider.dart'; // Import provider package

// Import your services and repositories
import 'services/firestore_service.dart';
import 'repositories/user_repository.dart';
import 'repositories/foreman_repository.dart';
import 'repositories/workshop_repository.dart';

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
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'), // Example home page
    );
  }
}

// Example MyHomePage (content doesn't matter for this step)
class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: const Center(
        child: Text(
          'Providers are set up!',
        ),
      ),
    );
  }
}
