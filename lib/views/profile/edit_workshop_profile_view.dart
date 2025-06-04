import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workshop_system/viewmodels/profile/workshop_profile_viewmodel.dart';
import 'package:workshop_system/repositories/workshop_repository.dart';
import 'package:workshop_system/services/firestore_service.dart';
import 'package:workshop_system/services/auth_service.dart'; // Import AuthService
import 'package:workshop_system/repositories/user_repository.dart'; // Import UserRepository
import 'package:go_router/go_router.dart'; // Import go_router

class EditWorkshopProfileView extends StatefulWidget {
  final String workshopId;

  const EditWorkshopProfileView({super.key, required this.workshopId});

  @override
  State<EditWorkshopProfileView> createState() => _EditWorkshopProfileViewState();
}

class _EditWorkshopProfileViewState extends State<EditWorkshopProfileView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _typeOfWorkshopController;
  late TextEditingController _serviceProvidedController;
  late TextEditingController _paymentTermsController;
  late TextEditingController _operatingHourStartController;
  late TextEditingController _operatingHourEndController;
  late TextEditingController _workshopNameController;
  late TextEditingController _addressController;
  late TextEditingController _workshopContactNumberController;
  late TextEditingController _workshopEmailController;
  late TextEditingController _facilitiesController;

  @override
  void initState() {
    super.initState();
    _typeOfWorkshopController = TextEditingController();
    _serviceProvidedController = TextEditingController();
    _paymentTermsController = TextEditingController();
    _operatingHourStartController = TextEditingController();
    _operatingHourEndController = TextEditingController();
    _workshopNameController = TextEditingController();
    _addressController = TextEditingController();
    _workshopContactNumberController = TextEditingController();
    _workshopEmailController = TextEditingController();
    _facilitiesController = TextEditingController();
  }

  @override
  void dispose() {
    _typeOfWorkshopController.dispose();
    _serviceProvidedController.dispose();
    _paymentTermsController.dispose();
    _operatingHourStartController.dispose();
    _operatingHourEndController.dispose();
    _workshopNameController.dispose();
    _addressController.dispose();
    _workshopContactNumberController.dispose();
    _workshopEmailController.dispose();
    _facilitiesController.dispose();
    super.dispose();
  }

  void _populateFields(WorkshopProfileViewModel viewModel) {
    final workshop = viewModel.workshop;
    if (workshop != null) {
      _typeOfWorkshopController.text = workshop.typeOfWorkshop;
      _serviceProvidedController.text = workshop.serviceProvided.join(', ');
      _paymentTermsController.text = workshop.paymentTerms;
      _operatingHourStartController.text = workshop.operatingHourStart;
      _operatingHourEndController.text = workshop.operatingHourEnd;
      _workshopNameController.text = workshop.workshopName ?? '';
      _addressController.text = workshop.address ?? '';
      _workshopContactNumberController.text = workshop.workshopContactNumber ?? '';
      _workshopEmailController.text = workshop.workshopEmail ?? '';
      _facilitiesController.text = workshop.facilities ?? '';
    }
  }

  void _saveProfile(WorkshopProfileViewModel viewModel) {
    if (_formKey.currentState!.validate()) {
      viewModel.updateWorkshopProfile(
        typeOfWorkshop: _typeOfWorkshopController.text,
        serviceProvided: _serviceProvidedController.text.split(',').map((e) => e.trim()).toList(),
        paymentTerms: _paymentTermsController.text,
        operatingHourStart: _operatingHourStartController.text,
        operatingHourEnd: _operatingHourEndController.text,
        workshopName: _workshopNameController.text,
        address: _addressController.text,
        workshopContactNumber: _workshopContactNumberController.text,
        workshopEmail: _workshopEmailController.text,
        facilities: _facilitiesController.text,
      );
    }
  }

  void _confirmAndDeleteAccount(WorkshopProfileViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
              'Are you sure you want to delete your account? This action is permanent and cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                final success = await viewModel.requestAccountDeletion();

                if (!mounted) return; // Guard against using context after async gap

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account deleted successfully.')),
                  );
                  if (!mounted) return; // Guard again before navigation
                  context.go('/welcome'); // Navigate to welcome/login screen
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete account: ${viewModel.errorMessage ?? "Unknown error"}')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workshop Profile'),
      ),
      body: ChangeNotifierProvider(
        create: (context) => WorkshopProfileViewModel(
          workshopRepository: Provider.of<WorkshopRepository>(context, listen: false),
          firestoreService: Provider.of<FirestoreService>(context, listen: false),
          authService: Provider.of<AuthService>(context, listen: false), // Pass AuthService
          userRepository: Provider.of<UserRepository>(context, listen: false), // Pass UserRepository
        )..loadWorkshopProfile(widget.workshopId),
        child: Consumer<WorkshopProfileViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage != null) {
              return Center(child: Text('Error: ${viewModel.errorMessage}'));
            }

            if (viewModel.workshop == null) {
              return const Center(child: Text('No workshop profile found.'));
            }

            _populateFields(viewModel); // Populate fields when data is loaded

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _workshopNameController,
                      decoration: const InputDecoration(labelText: 'Workshop Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter workshop name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _typeOfWorkshopController,
                      decoration: const InputDecoration(labelText: 'Type of Workshop'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter type of workshop';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _serviceProvidedController,
                      decoration: const InputDecoration(labelText: 'Services Provided (comma-separated)'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter services provided';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _paymentTermsController,
                      decoration: const InputDecoration(labelText: 'Payment Terms'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter payment terms';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _operatingHourStartController,
                      decoration: const InputDecoration(labelText: 'Operating Hour Start (e.g., 09:00)'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter start hour';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _operatingHourEndController,
                      decoration: const InputDecoration(labelText: 'Operating Hour End (e.g., 17:00)'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter end hour';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Address'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _workshopContactNumberController,
                      decoration: const InputDecoration(labelText: 'Contact Number'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _workshopEmailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _facilitiesController,
                      decoration: const InputDecoration(labelText: 'Facilities'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: () => _saveProfile(viewModel),
                        child: const Text('Save Profile'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: () => _confirmAndDeleteAccount(viewModel),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text(
                          'Delete Account',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
