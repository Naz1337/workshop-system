import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:workshop_system/main.dart';
import 'package:workshop_system/data/services/firestore_service.dart';
import 'package:workshop_system/data/repositories/schedule_repository.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Create dependencies
    final firestoreService = FirestoreService();
    final scheduleRepository = ScheduleRepository(firestoreService: firestoreService);

    // Build the app
    await tester.pumpWidget(MyApp(scheduleRepository: scheduleRepository));

    // Just test that the app loads without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}