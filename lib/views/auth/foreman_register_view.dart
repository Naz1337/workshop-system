import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth/foreman_register_viewmodel.dart';
import '../../services/auth_service.dart';
import '../../repositories/user_repository.dart';
import '../../repositories/foreman_repository.dart';

class ForemanRegisterView extends StatefulWidget {
  const ForemanRegisterView({super.key});

  @override
  State<ForemanRegisterView> createState() => _ForemanRegisterViewState();
}

class _ForemanRegisterViewState extends State<ForemanRegisterView> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _contactInfoController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _pastExperienceController = TextEditingController();
  final TextEditingController _resumeUrlController = TextEditingController();
  final TextEditingController _bankAccountNoController = TextEditingController();
  final TextEditingController _yearsOfExperienceController = TextEditingController();


  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _contactInfoController.dispose();
    _skillsController.dispose();
    _pastExperienceController.dispose();
    _resumeUrlController.dispose();
    _bankAccountNoController.dispose();
    _yearsOfExperienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register as Foreman')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ChangeNotifierProvider(
          create: (_) => ForemanRegisterViewModel(
            Provider.of<AuthService>(context, listen: false),
            Provider.of<UserRepository>(context, listen: false),
            Provider.of<ForemanRepository>(context, listen: false),
          ),
          child: Consumer<ForemanRegisterViewModel>(
            builder: (context, viewModel, child) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(labelText: 'Full Name'),
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
                      controller: _contactInfoController,
                      decoration: const InputDecoration(labelText: 'Contact Info'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _skillsController,
                      decoration: const InputDecoration(labelText: 'Skills (comma-separated)'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _pastExperienceController,
                      decoration: const InputDecoration(labelText: 'Past Experience'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _resumeUrlController,
                      decoration: const InputDecoration(labelText: 'Resume URL (Optional)'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _bankAccountNoController,
                      decoration: const InputDecoration(labelText: 'Bank Account Number'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _yearsOfExperienceController,
                      decoration: const InputDecoration(labelText: 'Years of Experience'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    if (viewModel.isLoading)
                      const CircularProgressIndicator()
                    else
                      ElevatedButton(
                        onPressed: () async {
                          await viewModel.registerForeman(
                            fullName: _fullNameController.text,
                            email: _emailController.text,
                            password: _passwordController.text,
                            confirmPassword: _confirmPasswordController.text,
                            contactInfo: _contactInfoController.text,
                            skills: _skillsController.text,
                            pastExperience: _pastExperienceController.text,
                            resumeUrl: _resumeUrlController.text,
                            bankAccountNo: _bankAccountNoController.text,
                            yearsOfExperience: int.tryParse(_yearsOfExperienceController.text) ?? 0,
                          );
                          if (viewModel.errorMessage == null) {
                            context.go('/home'); // Navigate on successful registration
                          }
                        },
                        child: const Text('Register as Foreman'),
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
                        context.push('/register/workshop'); // Navigate to workshop registration
                      },
                      child: const Text('Are you a Workshop Owner? Register here.'),
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
