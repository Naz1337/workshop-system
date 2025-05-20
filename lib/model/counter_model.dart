import 'dart:async';
import 'dart:math'; // For simulating errors

// Represents the data structure for our counter.
class CounterData {
  CounterData(this.count);
  final int count;
}

// Handles the low-level logic of fetching/updating the counter data.
// In a real app, this would interact with a database, network API, etc.
class CounterModel {
  int _currentCount = 0; // Simulate server-side state
  final _random = Random(); // To simulate potential network errors

  // Simulates fetching the count from a server.
  Future<CounterData> loadCountFromServer() async {
    print('MODEL: Attempting to load count from server...');
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Simulate a potential network/server error (e.g., 1 in 5 chance)
    if (_random.nextInt(5) == 0) {
      print('MODEL: Error loading count!');
      throw ('Failed to load count from the server.');
    }

    // Simulate successful fetch
    print('MODEL: Count loaded successfully: $_currentCount');
    return CounterData(_currentCount);
  }

  // Simulates updating the count on a server.
  Future<CounterData> updateCountOnServer(int newCount) async {
    print('MODEL: Attempting to update count on server to $newCount...');
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Simulate a potential network/server error (e.g., 1 in 5 chance)
    if (_random.nextInt(5) == 0) {
       print('MODEL: Error updating count!');
      throw ('Failed to update count on the server.');
    }

    // Simulate successful update
    _currentCount = newCount;
    print('MODEL: Count updated successfully to: $_currentCount');
    return CounterData(_currentCount);
  }
}
