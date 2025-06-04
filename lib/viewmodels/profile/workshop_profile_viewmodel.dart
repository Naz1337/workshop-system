import 'package:flutter/material.dart';
import 'package:workshop_system/models/workshop_model.dart';
import 'package:workshop_system/repositories/workshop_repository.dart';
import 'package:workshop_system/services/firestore_service.dart'; // Assuming FirestoreService handles general data operations
import 'package:workshop_system/services/auth_service.dart'; // Import AuthService
import 'package:workshop_system/repositories/user_repository.dart'; // Import UserRepository

class WorkshopProfileViewModel extends ChangeNotifier {
  final WorkshopRepository _workshopRepository;
  final FirestoreService _firestoreService; // For potential file uploads
  final AuthService _authService; // Add AuthService
  final UserRepository _userRepository; // Add UserRepository

  Workshop? _workshop;
  bool _isLoading = false;
  String? _errorMessage;

  Workshop? get workshop => _workshop;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  WorkshopProfileViewModel({
    required WorkshopRepository workshopRepository,
    required FirestoreService firestoreService,
    required AuthService authService, // Initialize AuthService
    required UserRepository userRepository, // Initialize UserRepository
  })  : _workshopRepository = workshopRepository,
        _firestoreService = firestoreService,
        _authService = authService, // Assign AuthService
        _userRepository = userRepository; // Assign UserRepository

  Future<void> loadWorkshopProfile(String workshopId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _workshop = await _workshopRepository.getWorkshop(workshopId);
    } catch (e) {
      _errorMessage = 'Failed to load workshop profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> requestAccountDeletion() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = _authService.getCurrentUser()?.uid;
      if (userId == null) {
        throw Exception('No authenticated user found.');
      }

      // Delete workshop specific data first
      await _workshopRepository.deleteWorkshop(userId);
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

  Future<void> updateWorkshopProfile({
    String? typeOfWorkshop,
    List<String>? serviceProvided,
    String? paymentTerms,
    String? operatingHourStart,
    String? operatingHourEnd,
    String? workshopName,
    String? address,
    String? workshopContactNumber,
    String? workshopEmail,
    String? facilities,
  }) async {
    if (_workshop == null) {
      _errorMessage = 'No workshop profile loaded to update.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedWorkshop = _workshop!.copyWith(
        typeOfWorkshop: typeOfWorkshop,
        serviceProvided: serviceProvided,
        paymentTerms: paymentTerms,
        operatingHourStart: operatingHourStart,
        operatingHourEnd: operatingHourEnd,
        workshopName: workshopName,
        address: address,
        workshopContactNumber: workshopContactNumber,
        workshopEmail: workshopEmail,
        facilities: facilities,
      );

      await _workshopRepository.updateWorkshop(updatedWorkshop);
      _workshop = updatedWorkshop; // Update local state
    } catch (e) {
      _errorMessage = 'Failed to update workshop profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
