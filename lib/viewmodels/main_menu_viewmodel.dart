import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:workshop_system/models/app_user_model.dart';
import 'package:workshop_system/repositories/user_repository.dart';
import 'package:workshop_system/services/auth_service.dart';

class MainMenuViewModel extends ChangeNotifier {
  final AuthService _authService;
  final UserRepository _userRepository;

  AppUser? _currentUser;
  bool _isForeman = false;
  bool _isWorkshopOwner = false;
  bool _isLoading = false;
  String? _errorMessage;

  MainMenuViewModel({
    required AuthService authService,
    required UserRepository userRepository,
  })  : _authService = authService,
        _userRepository = userRepository {
    _initializeUserRole();
  }

  AppUser? get currentUser => _currentUser;
  bool get isForeman => _isForeman;
  bool get isWorkshopOwner => _isWorkshopOwner;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> _initializeUserRole() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    debugPrint('[MainMenuViewModel] Initializing user role...');

    try {
      final firebaseUser = _authService.getCurrentUser();
      if (firebaseUser != null) {
        debugPrint('[MainMenuViewModel] Firebase User ID: ${firebaseUser.uid}');
        _currentUser = await _userRepository.getUser(firebaseUser.uid);
        debugPrint('[MainMenuViewModel] AppUser data: ${_currentUser?.toMap().toString()}');

        if (_currentUser != null) {
          debugPrint('[MainMenuViewModel] AppUser role from DB: ${_currentUser!.role}');
          final userRole = _currentUser!.role.toLowerCase(); // Convert to lowercase
          debugPrint('[MainMenuViewModel] AppUser role (lowercase): $userRole');
          _isForeman = userRole == 'foreman';
          _isWorkshopOwner = userRole == 'workshop_owner';
          debugPrint('[MainMenuViewModel] isForeman: $_isForeman, isWorkshopOwner: $_isWorkshopOwner');
        } else {
          _errorMessage = "User data not found in Firestore for UID: ${firebaseUser.uid}.";
          debugPrint('[MainMenuViewModel] $_errorMessage');
        }
      } else {
        _errorMessage = "No authenticated Firebase user found.";
        debugPrint('[MainMenuViewModel] $_errorMessage');
      }
    } catch (e) {
      _errorMessage = "Failed to load user data: ${e.toString()}";
      debugPrint('[MainMenuViewModel] Error initializing user role: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('[MainMenuViewModel] User role initialization complete. isLoading: $_isLoading');
    }
  }

  // Navigation methods (to be called from the View)
  void navigateToUserProfile(BuildContext context) {
    if (_currentUser == null) {
      debugPrint("Error: Current user is null, cannot navigate to profile.");
      // Optionally, show a snackbar or dialog to the user
      return;
    }

    if (_isForeman) {
      context.push('/profile/foreman/${_currentUser!.id}');
    } else if (_isWorkshopOwner) {
      context.push('/profile/workshop/${_currentUser!.id}');
    } else {
      debugPrint("Error: User role not determined, cannot navigate to profile.");
      // Optionally, show a snackbar or dialog
    }
  }

  void goToBrowseWorkshops() {
    // This will be handled by go_router in the View
  }

  void goToAvailableWorkshops() {
    // This will be handled by go_router in the View
  }

  void goToPendingApplications() {
    // This will be handled by go_router in the View
  }

  void goToForemanRequests() {
    // This will be handled by go_router in the View
  }

  void navigateToWorkshopSearch(BuildContext context) {
    context.push('/foreman/search-workshops');
  }

  void goToWhitelistedForemen() {
    // This will be handled by go_router in the View
  }

  void goToManageSchedule() {
    // This will be handled by go_router in the View
  }

  Future<void> logout() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.signOut();
      // After logout, navigation to login/welcome screen will be handled by AuthWrapper or similar in main.dart
    } catch (e) {
      _errorMessage = "Logout failed: ${e.toString()}";
      debugPrint('Error during logout: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
