import 'package:flutter/material.dart';
import 'package:workshop_system/models/foreman_model.dart';
import 'package:workshop_system/repositories/foreman_repository.dart';
import 'package:workshop_system/services/firestore_service.dart';
import 'package:workshop_system/services/auth_service.dart'; // Import AuthService
import 'package:workshop_system/repositories/user_repository.dart'; // Import UserRepository

class ForemanProfileViewModel extends ChangeNotifier {
  final ForemanRepository _foremanRepository;
  final FirestoreService _firestoreService;
  final AuthService _authService; // Add AuthService
  final UserRepository _userRepository; // Add UserRepository

  Foreman? _foreman;
  bool _isLoading = false;
  String? _errorMessage;

  Foreman? get foreman => _foreman;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ForemanProfileViewModel({
    required ForemanRepository foremanRepository,
    required FirestoreService firestoreService,
    required AuthService authService, // Initialize AuthService
    required UserRepository userRepository, // Initialize UserRepository
  })  : _foremanRepository = foremanRepository,
        _firestoreService = firestoreService,
        _authService = authService, // Assign AuthService
        _userRepository = userRepository; // Assign UserRepository

  Future<void> loadForemanProfile(String foremanId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _foreman = await _foremanRepository.getForeman(foremanId);
    } catch (e) {
      _errorMessage = 'Failed to load foreman profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateForemanProfile({
    String? foremanName,
    String? foremanEmail,
    String? foremanBankAccountNo,
    int? yearsOfExperience,
    String? pastExperienceDetails,
    String? skills,
  }) async {
    if (_foreman == null) {
      _errorMessage = 'No foreman profile loaded to update.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedForeman = _foreman!.copyWith(
        foremanName: foremanName,
        foremanEmail: foremanEmail,
        foremanBankAccountNo: foremanBankAccountNo,
        yearsOfExperience: yearsOfExperience,
        pastExperienceDetails: pastExperienceDetails,
        skills: skills,
      );

      await _foremanRepository.updateForeman(updatedForeman);
      _foreman = updatedForeman; // Update local state
    } catch (e) {
      _errorMessage = 'Failed to update foreman profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Future<void> uploadResume(File resumeFile) async {
  //   _isLoading = true;
  //   _errorMessage = null;
  //   notifyListeners();

  //   try {
  //     // Assuming FirestoreService has a method for file uploads to Firebase Storage
  //     // This would return a URL to the uploaded file
  //     final String? resumeUrl = await _firestoreService.uploadFile(
  //       file: resumeFile,
  //       path: 'resumes/${_foreman!.id}', // Example path
  //     );

  //     if (resumeUrl != null) {
  //       final updatedForeman = _foreman!.copyWith(resumeUrl: resumeUrl);
  //       await _foremanRepository.updateForeman(updatedForeman);
  //       _foreman = updatedForeman;
  //     } else {
  //       _errorMessage = 'Resume upload failed.';
  //     }
  //   } catch (e) {
  //     _errorMessage = 'Failed to upload resume: $e';
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  Future<bool> requestAccountDeletion() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _authService.getCurrentUser()?.uid;
      if (userId == null) {
        throw Exception('No authenticated user found.');
      }

      // Delete foreman specific data first
      await _foremanRepository.deleteForeman(userId);
      // Delete general user data
      await _userRepository.deleteUser(userId);
      // Delete Firebase Auth user
      await _authService.deleteCurrentUserAccount();

      return true;
    } on Exception catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
