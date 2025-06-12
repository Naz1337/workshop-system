import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodels/manage_rating/feedback_view_model.dart';
import 'services/rating_service.dart';  // Updated import
import 'repositories/rating_repository.dart';
import 'views/manage_rating/user_rating_screen.dart';
import 'views/manage_rating/all_ratings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override

  Widget build(BuildContext context) {
    final repository = RatingRepository(
      ratingService: RatingService(), // Now using real Firebase service
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => FeedbackViewModel(
            ratingRepository: repository,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Car Workshop Feedback',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
        ),
        // Set initial route
        initialRoute: '/rating',
        // Define named routes
        routes: {
          '/rating': (context) => const UserRatingScreen(),
          '/all-ratings': (context) => const AllRatingsScreen(),
        },
      ),
    );
  }

  
}