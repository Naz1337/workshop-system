import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../repositories/user_repository.dart';
import '../../repositories/workshop_repository.dart';
import '../../models/app_user_model.dart';
import '../../models/workshop_model.dart';

class WorkshopRegisterViewModel extends ChangeNotifier {
  final AuthService _authService;
  final UserRepository _userRepository;
  final WorkshopRepository _workshopRepository;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  WorkshopRegisterViewModel(this._authService, this._userRepository, this._workshopRepository);

  Future<void> registerWorkshop({
    required String workshopName,
    required String email,
    required String password,
    required String confirmPassword,
    required String workshopAddress,
    required String contactInfo,
    required String servicesOffered,
    required String paymentTerms,
    required String operatingHourStart,
    required String operatingHourEnd,
    required String typeOfWorkshop, // Add this new parameter
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (password != confirmPassword) {
      _errorMessage = 'Passwords do not match.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      UserCredential? userCredential = await _authService.registerWithEmailAndPassword(email, password);
      if (userCredential != null && userCredential.user != null) {
        final String userId = userCredential.user!.uid;

        // Create AppUser document
        final AppUser appUser = AppUser(
          id: userId,
          name: workshopName, // Using workshop name as user name for simplicity
          email: email,
          contactNumber: contactInfo,
          role: 'workshop_owner',
        );
        await _userRepository.createUserDocument(appUser);

        // Create Workshop profile
        final Workshop workshop = Workshop(
          id: userId, // Use user ID as workshop ID
          ownerId: userId,
          typeOfWorkshop: typeOfWorkshop, // Use the actual type from the new input
          serviceProvided: servicesOffered.split(',').map((s) => s.trim()).toList(),
          paymentTerms: paymentTerms,
          operatingHourStart: operatingHourStart,
          operatingHourEnd: operatingHourEnd,
          workshopName: workshopName, // Denormalize workshop name from user input
          address: workshopAddress,
          workshopContactNumber: contactInfo,
          workshopEmail: email, // Use registration email as workshop email
        );
        await _workshopRepository.createWorkshop(workshop);
      }
    } on Exception catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
