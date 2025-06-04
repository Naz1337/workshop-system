import 'package:flutter/material.dart'; // Required for BuildContext
import 'package:go_router/go_router.dart'; // Required for context.push
import 'package:workshop_system/models/workshop_model.dart';
import 'package:workshop_system/repositories/workshop_repository.dart';

class WorkshopSearchViewModel extends ChangeNotifier {
  final WorkshopRepository _workshopRepository;

  List<Workshop> _workshops = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  WorkshopSearchViewModel({required WorkshopRepository workshopRepository})
      : _workshopRepository = workshopRepository {
    _searchWorkshops(); // Initial load
  }

  List<Workshop> get workshops => _workshops;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  set searchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> _searchWorkshops() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _workshops = await _workshopRepository.searchWorkshops(query: _searchQuery);
    } catch (e) {
      _errorMessage = "Failed to search workshops: ${e.toString()}";
      debugPrint('Error searching workshops: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void onSearchQueryChanged(String query) {
    searchQuery = query;
    _searchWorkshops();
  }

  void selectWorkshop(BuildContext context, String workshopId) {
    context.push('/profile/workshop/$workshopId');
  }
}
