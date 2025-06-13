import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import 'services/firestore_service.dart';
import 'services/auth_service.dart';
import 'services/inventory_service.dart';
import 'repositories/user_repository.dart';
import 'repositories/foreman_repository.dart';
import 'repositories/workshop_repository.dart';
import 'repositories/payroll_repository.dart';
import 'models/app_user_model.dart';
import 'config/router.dart';

// ✅ Import your InventoryViewModel
import 'viewmodels/inventory/inventory_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        // Service Providers
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<InventoryService>(create: (_) => InventoryService()),

        // ✅ Add your InventoryViewModel provider
        ChangeNotifierProvider<InventoryViewModel>(
          create: (_) => InventoryViewModel(),
        ),

        // Repository Providers
        ProxyProvider<FirestoreService, UserRepository>(
          update: (_, firestoreService, __) => UserRepository(firestoreService),
        ),
        ProxyProvider<FirestoreService, ForemanRepository>(
          update:
              (_, firestoreService, __) => ForemanRepository(firestoreService),
        ),
        ProxyProvider2<FirestoreService, UserRepository, WorkshopRepository>(
          update:
              (_, firestoreService, userRepository, __) =>
                  WorkshopRepository(firestoreService, userRepository),
        ),
        Provider<PayrollRepository>(create: (_) => PayrollRepository()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'Workshop Management System',
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
