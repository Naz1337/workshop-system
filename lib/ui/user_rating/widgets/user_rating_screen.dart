import 'package:flutter/material.dart';

import '../view_model/user_rating_viewmodel.dart';

class UserRatingScreen extends StatelessWidget {
  var user_rating_view_model;
  
  UserRatingScreen(UserRatingViewModel user_rating_view_model) {
    user_rating_view_model = user_rating_view_model;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Text('Rating');
  }
}