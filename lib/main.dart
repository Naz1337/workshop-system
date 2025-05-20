import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workshop_system/controllers/rating_controller.dart';
import 'package:workshop_system/repository/rating_repository.dart';
import 'package:workshop_system/ui/manage_rating/feedback_view_model.dart'; 
import 'package:workshop_system/ui/manage_rating/user_rating_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // Initialize dependencies
        Provider(create: (_) => RatingRepositoryImpl()),
        ChangeNotifierProvider(
          create: (context) => FeedbackViewModel(
            ratingController: RatingController(
              ratingRepository: Provider.of<RatingRepository>(context, listen: false),
            ),
          ),
        ),
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
      title: 'Workshop Management System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const UserRatingScreen(),
    );
  }
}