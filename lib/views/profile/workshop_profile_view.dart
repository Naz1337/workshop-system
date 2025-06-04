import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workshop_system/viewmodels/profile/workshop_profile_viewmodel.dart';
import 'package:workshop_system/repositories/workshop_repository.dart';
import 'package:workshop_system/services/firestore_service.dart';

class WorkshopProfileView extends StatefulWidget {
  final String workshopId;

  const WorkshopProfileView({Key? key, required this.workshopId}) : super(key: key);

  @override
  State<WorkshopProfileView> createState() => _WorkshopProfileViewState();
}

class _WorkshopProfileViewState extends State<WorkshopProfileView> {
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
