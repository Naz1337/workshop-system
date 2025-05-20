import 'package:flutter/material.dart';
<<<<<<< Updated upstream
<<<<<<< Updated upstream
=======
import 'model/counter_model.dart';
import 'viewmodel/counter_viewmodel.dart';
import 'view/counter_view.dart';
>>>>>>> Stashed changes
=======
import 'model/counter_model.dart';
import 'viewmodel/counter_viewmodel.dart';
import 'view/counter_view.dart';
>>>>>>> Stashed changes

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter MVVM Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(),
    );
  }
}

// This StatefulWidget is responsible for creating and initializing
// the ViewModel and providing it to the View.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Create instances of Model and ViewModel here.
  // They will persist for the lifetime of this State.
  late final CounterModel _model;
  late final CounterViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    print('MAIN: Initializing Model and ViewModel...');
    // 1. Create the Model
    _model = CounterModel();
    // 2. Create the ViewModel, passing the Model to it
    _viewModel = CounterViewModel(_model);
    // 3. Initialize the ViewModel (which will load initial data)
    _viewModel.init();
     print('MAIN: ViewModel initialization triggered.');
  }

  @override
  Widget build(BuildContext context) {
    print('MAIN: Building MyHomePage Scaffold...');
    return Scaffold(
      appBar: AppBar(
        title: const Text('MVVM Counter Example'),
      ),
      body: Center(
        // 4. Provide the ViewModel instance to the View widget
        child: CounterView(viewModel: _viewModel),
      ),
    );
  }
}
