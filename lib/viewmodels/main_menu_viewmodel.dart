import 'package:flutter/foundation.dart';
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

    try {
      final firebaseUser = _authService.getCurrentUser();
      if (firebaseUser != null) {
        _currentUser = await _userRepository.getUser(firebaseUser.uid);
        if (_currentUser != null) {
          _isForeman = _currentUser!.role == 'foreman';
          _isWorkshopOwner = _currentUser!.role == 'workshop_owner';
        } else {
          _errorMessage = "User data not found.";
        }
      } else {
        _errorMessage = "No authenticated user found.";
      }
    } catch (e) {
      _errorMessage = "Failed to load user data: ${e.toString()}";
      debugPrint('Error initializing user role: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Navigation methods (to be called from the View)
  void goToProfile() {
    // This will be handled by go_router in the View
    // The ViewModel just exposes the intention
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
