import 'package:flutter/foundation.dart';
import '../model/counter_model.dart'; // Import the model

// Binds the View to the Model using ChangeNotifier.
class CounterViewModel extends ChangeNotifier {
  final CounterModel _model; // Holds a reference to the model

  // Private state variables
  int? _count;
  String? _errorMessage;
  bool _isLoading = false; // To track loading state for the UI

  // Constructor requires the model
  CounterViewModel(this._model);

  // Public getters for the View to access the state
  int? get count => _count;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  // Initialization logic - typically called when the ViewModel is first created.
  Future<void> init() async {
    print('VIEWMODEL: Initializing...');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Notify UI that loading has started

    try {
      final counterData = await _model.loadCountFromServer();
      _count = counterData.count;
      print('VIEWMODEL: Initialization successful. Count: $_count');
    } catch (e) {
      _errorMessage = e.toString();
      print('VIEWMODEL: Initialization failed. Error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify UI that loading is finished (success or error)
    }
  }

  // Action method for the View to call (e.g., when a button is pressed).
  Future<void> increment() async {
    print('VIEWMODEL: Increment requested.');
    if (_isLoading) {
      print('VIEWMODEL: Already processing, increment ignored.');
      return; // Don't allow multiple increments while one is in progress
    }
    if (_count == null) {
      _errorMessage = 'Counter not initialized yet.';
      print('VIEWMODEL: Cannot increment, not initialized.');
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Notify UI that loading has started

    try {
      final int incrementedCount = _count! + 1;
      final updatedData = await _model.updateCountOnServer(incrementedCount);
      _count = updatedData.count; // Update state with the confirmed new count
      print('VIEWMODEL: Increment successful. New count: $_count');
    } catch (e) {
      _errorMessage = e.toString();
      print('VIEWMODEL: Increment failed. Error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify UI that loading is finished (success or error)
    }
  }
}
