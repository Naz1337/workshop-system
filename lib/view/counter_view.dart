import 'package:flutter/material.dart';
import '../viewmodel/counter_viewmodel.dart'; // Import the viewmodel

// The UI (View) part of MVVM. It listens to the ViewModel for state changes.
class CounterView extends StatelessWidget {
  final CounterViewModel viewModel; // Receives the ViewModel instance

  const CounterView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder rebuilds its child widget tree whenever the
    // viewModel notifies its listeners.
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        print('VIEW: Rebuilding...');
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Display Error Message if any
            if (viewModel.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Error: ${viewModel.errorMessage}',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),

            // Display Loading Indicator or Count
            if (viewModel.isLoading)
              const CircularProgressIndicator()
            else
              Text(
                'Count: ${viewModel.count ?? 'Loading...'}', // Show 'Loading...' if count is null
                style: Theme.of(context).textTheme.headlineMedium,
              ),

            const SizedBox(height: 20),

            // Button to trigger the increment action
            ElevatedButton(
              // Disable button while loading to prevent multiple clicks
              onPressed: viewModel.isLoading ? null : () {
                print('VIEW: Increment button pressed.');
                viewModel.increment(); // Call the ViewModel's action method
              },
              child: const Text('Increment'),
            ),
          ],
        );
      },
    );
  }
}
