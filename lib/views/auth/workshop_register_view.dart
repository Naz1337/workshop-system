import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth/workshop_register_viewmodel.dart';
import '../../services/auth_service.dart';
import '../../repositories/user_repository.dart';
import '../../repositories/workshop_repository.dart';

class WorkshopRegisterView extends StatefulWidget {
  const WorkshopRegisterView({super.key});

  @override
  State<WorkshopRegisterView> createState() => _WorkshopRegisterViewState();
}

class _WorkshopRegisterViewState extends State<WorkshopRegisterView> {
  final TextEditingController _workshopNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _workshopAddressController = TextEditingController();
  final TextEditingController _contactInfoController = TextEditingController();
  final TextEditingController _servicesOfferedController = TextEditingController();
  final TextEditingController _paymentTermsController = TextEditingController();
  final TextEditingController _operatingHourStartController = TextEditingController();
  final TextEditingController _operatingHourEndController = TextEditingController();
  final TextEditingController _typeOfWorkshopController = TextEditingController(); // New controller


  @override
  void dispose() {
    _workshopNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _workshopAddressController.dispose();
    _contactInfoController.dispose();
    _servicesOfferedController.dispose();
    _paymentTermsController.dispose();
    _operatingHourStartController.dispose();
    _operatingHourEndController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register as Workshop Owner')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ChangeNotifierProvider(
          create: (_) => WorkshopRegisterViewModel(
            Provider.of<AuthService>(context, listen: false),
            Provider.of<UserRepository>(context, listen: false),
            Provider.of<WorkshopRepository>(context, listen: false),
          ),
          child: Consumer<WorkshopRegisterViewModel>(
            builder: (context, viewModel, child) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _workshopNameController,
                      decoration: const InputDecoration(labelText: 'Workshop Name'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _confirmPasswordController,
                      decoration: const InputDecoration(labelText: 'Confirm Password'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _workshopAddressController,
                      decoration: const InputDecoration(labelText: 'Workshop Address'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _contactInfoController,
                      decoration: const InputDecoration(labelText: 'Contact Info'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _servicesOfferedController,
                      decoration: const InputDecoration(labelText: 'Services Offered (comma-separated)'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _paymentTermsController,
                      decoration: const InputDecoration(labelText: 'Payment Terms'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _operatingHourStartController,
                      decoration: const InputDecoration(labelText: 'Operating Hour Start (e.g., 09:00)'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _operatingHourEndController,
                      decoration: const InputDecoration(labelText: 'Operating Hour End (e.g., 17:00)'),
                    ),
                    const SizedBox(height: 10), // Add SizedBox for spacing
                    TextField( // New TextField for Type of Workshop
                      controller: _typeOfWorkshopController,
                      decoration: const InputDecoration(labelText: 'Type of Workshop'),
                    ),
                    const SizedBox(height: 20),
                    if (viewModel.isLoading)
                      const CircularProgressIndicator()
                    else
                      ElevatedButton(
                        onPressed: () async {
                          await viewModel.registerWorkshop(
                            workshopName: _workshopNameController.text,
                            email: _emailController.text,
                            password: _passwordController.text,
                            confirmPassword: _confirmPasswordController.text,
                            workshopAddress: _workshopAddressController.text,
                            contactInfo: _contactInfoController.text,
                            servicesOffered: _servicesOfferedController.text,
                            paymentTerms: _paymentTermsController.text,
                            operatingHourStart: _operatingHourStartController.text,
                            operatingHourEnd: _operatingHourEndController.text,
                            typeOfWorkshop: _typeOfWorkshopController.text, // Pass the new value
                          );
                          if (viewModel.errorMessage == null) {
                            context.go('/home'); // Navigate on successful registration
                          }
                        },
                        child: const Text('Register as Workshop Owner'),
                      ),
                    if (viewModel.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          viewModel.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        context.push('/register/foreman'); // Navigate to foreman registration
                      },
                      child: const Text('Are you a Foreman? Register here.'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
