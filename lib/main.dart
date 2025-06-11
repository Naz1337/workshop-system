import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// ADD THIS LINE - Import Firebase options
import 'firebase_options.dart';

import 'data/repositories/schedule_repository.dart';
import 'data/services/firestore_service.dart';
import 'views/manage_schedule/schedule_overview_page.dart';
import 'views/manage_schedule/create_schedule_page.dart';
import 'views/manage_schedule/slot_selection_page.dart';
import 'views/manage_schedule/my_schedule_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // CHANGE THIS LINE - Add options parameter
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

final _router = GoRouter(
  initialLocation: '/overview/test-workshop-id',
  routes: [
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