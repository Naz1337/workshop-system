import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../repositories/user_repository.dart';
import '../../repositories/foreman_repository.dart';
import '../../models/app_user_model.dart';
import '../../models/foreman_model.dart';

class ForemanRegisterViewModel extends ChangeNotifier {
  final AuthService _authService;
  final UserRepository _userRepository;
  final ForemanRepository _foremanRepository;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ForemanRegisterViewModel(this._authService, this._userRepository, this._foremanRepository);

  Future<void> registerForeman({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
    required String contactInfo,
    required String skills,
    required String pastExperience,
    String? resumeUrl,
    required String bankAccountNo,
    required int yearsOfExperience,
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
          name: fullName,
          email: email,
          contactNumber: contactInfo,
          role: 'foreman',
        );
        await _userRepository.createUserDocument(appUser);

        // Create Foreman profile
        final Foreman foremanProfile = Foreman(
          id: userId, // Use user ID as foreman ID
          userId: userId,
          foremanName: fullName,
          foremanEmail: email,
          foremanBankAccountNo: bankAccountNo,
          yearsOfExperience: yearsOfExperience,
          // ratingId and resumeURL can be null initially
          resumeUrl: resumeUrl,
        );
        await _foremanRepository.createForemanProfile(foremanProfile);
      }
    } on Exception catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
