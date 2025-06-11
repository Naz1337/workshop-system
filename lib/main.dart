// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import 'data/repositories/schedule_repository.dart';
import 'data/services/firestore_service.dart';
import 'views/manage_schedule/schedule_overview_page.dart';
import 'views/manage_schedule/create_schedule_page.dart';
import 'views/manage_schedule/slot_selection_page.dart';
import 'views/manage_schedule/my_schedule_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestoreService = FirestoreService();
  final scheduleRepository = ScheduleRepository(firestoreService: firestoreService);

  runApp(MyApp(scheduleRepository: scheduleRepository));
}

class MyApp extends StatelessWidget {
  final ScheduleRepository scheduleRepository;

  const MyApp({super.key, required this.scheduleRepository});

  @override
  Widget build(BuildContext context) {
    return Provider<ScheduleRepository>.value(
      value: scheduleRepository,
      child: MaterialApp.router(
        title: 'Workshop System',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routerConfig: _router,
      ),
    );
  }
}

// FIXED: Added proper navigation flow and demo navigation
final _router = GoRouter(
  initialLocation: '/demo', // Start with demo navigation
  routes: [
    // Demo home page with navigation options
    GoRoute(
      path: '/demo',
      builder: (context, state) => const DemoHomePage(),
    ),
    // Workshop Owner Routes
    GoRoute(
      path: '/overview/:workshopId',
      builder: (context, state) => ScheduleOverviewPage(
        workshopId: state.pathParameters['workshopId']!,
      ),
    ),
    GoRoute(
      path: '/create-schedule/:workshopId',
      builder: (context, state) => CreateSchedulePage(
        workshopId: state.pathParameters['workshopId']!,
      ),
    ),
    // Foreman Routes  
    GoRoute(
      path: '/select-slot/:foremanId',
      builder: (context, state) => SlotSelectionPage(
        foremanId: state.pathParameters['foremanId']!,
      ),
    ),
    GoRoute(
      path: '/my-schedule/:foremanId',
      builder: (context, state) => MySchedulePage(
        foremanId: state.pathParameters['foremanId']!,
      ),
    ),
  ],
);

// Demo home page to navigate between different user roles
class DemoHomePage extends StatelessWidget {
  const DemoHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workshop Management System'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select User Role',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            
            // Workshop Owner Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Workshop Owner',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.push('/overview/demo-workshop-123'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Manage Schedules'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Foreman Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Foreman',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => context.push('/select-slot/demo-foreman-123'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Book Slots'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => context.push('/my-schedule/demo-foreman-123'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('My Schedule'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            const Text(
              'Note: This demo uses test IDs for demonstration purposes',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}