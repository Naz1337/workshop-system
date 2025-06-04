import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workshop_system/viewmodels/profile/foreman_profile_viewmodel.dart';
import 'package:workshop_system/repositories/foreman_repository.dart';
import 'package:workshop_system/services/firestore_service.dart';
import 'package:workshop_system/services/auth_service.dart'; // Import AuthService
import 'package:workshop_system/repositories/user_repository.dart'; // Import UserRepository
import 'package:go_router/go_router.dart'; // Import go_router

class EditForemanProfileView extends StatefulWidget {
  final String foremanId;

  const EditForemanProfileView({Key? key, required this.foremanId}) : super(key: key);

  @override
  State<EditForemanProfileView> createState() => _EditForemanProfileViewState();
}

class _EditForemanProfileViewState extends State<EditForemanProfileView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _bankAccountController;
  late TextEditingController _experienceController;
  late TextEditingController _pastExperienceController;
  late TextEditingController _skillsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _bankAccountController = TextEditingController();
    _experienceController = TextEditingController();
    _pastExperienceController = TextEditingController();
    _skillsController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bankAccountController.dispose();
    _experienceController.dispose();
    _pastExperienceController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  void _populateFields(ForemanProfileViewModel viewModel) {
    final foreman = viewModel.foreman;
    if (foreman != null) {
      _nameController.text = foreman.foremanName;
      _emailController.text = foreman.foremanEmail;
      _bankAccountController.text = foreman.foremanBankAccountNo;
      _experienceController.text = foreman.yearsOfExperience.toString();
      _pastExperienceController.text = foreman.pastExperienceDetails ?? '';
      _skillsController.text = foreman.skills ?? '';
    }
  }

  void _saveProfile(ForemanProfileViewModel viewModel) {
    if (_formKey.currentState!.validate()) {
      viewModel.updateForemanProfile(
        foremanName: _nameController.text,
        foremanEmail: _emailController.text,
        foremanBankAccountNo: _bankAccountController.text,
        yearsOfExperience: int.tryParse(_experienceController.text),
        pastExperienceDetails: _pastExperienceController.text,
        skills: _skillsController.text,
      );
    }
  }

  void _confirmAndDeleteAccount(ForemanProfileViewModel viewModel) {
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

                // Check if the widget is still mounted before using its context
                if (!mounted) return;

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account deleted successfully.')),
                  );
                  // Ensure context is still valid for navigation as well
                  if (mounted) {
                    context.go('/welcome'); // Navigate to welcome/login screen
                  }
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
        title: const Text('Foreman Profile'),
      ),
      body: ChangeNotifierProvider(
        create: (context) => ForemanProfileViewModel(
          foremanRepository: Provider.of<ForemanRepository>(context, listen: false),
          firestoreService: Provider.of<FirestoreService>(context, listen: false),
          authService: Provider.of<AuthService>(context, listen: false), // Pass AuthService
          userRepository: Provider.of<UserRepository>(context, listen: false), // Pass UserRepository
        )..loadForemanProfile(widget.foremanId),
        child: Consumer<ForemanProfileViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage != null) {
              return Center(child: Text('Error: ${viewModel.errorMessage}'));
            }

            if (viewModel.foreman == null) {
              return const Center(child: Text('No foreman profile found.'));
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
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bankAccountController,
                      decoration: const InputDecoration(labelText: 'Bank Account No.'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your bank account number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _experienceController,
                      decoration: const InputDecoration(labelText: 'Years of Experience'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter years of experience';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _pastExperienceController,
                      decoration: const InputDecoration(labelText: 'Past Experience Details'),
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _skillsController,
                      decoration: const InputDecoration(labelText: 'Skills (comma-separated)'),
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
